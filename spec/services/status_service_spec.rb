require 'rails_helper'

RSpec.describe StatusService, type: :service do
  let(:ship_id) { 1 }
  let(:trajectory_key) { 'future:grid:1000:0:0' }
  let(:own_trajectory_data) do
    { ship_id: ship_id, x: 5, y: 5, version: 'v1' }
  end
  let(:trajectory) { { trajectory_key => [own_trajectory_data] } }

  before do
    # Stub TrajectoryCacheService methods
    allow_any_instance_of(TrajectoryCacheService).to receive(:save_version)
    allow_any_instance_of(TrajectoryCacheService).to receive(:version).and_return(nil)
  end

  describe '#recognize_status' do
    context 'when ship is not moving' do
      let(:speed) { { main_speed: 0, speed_x: 0, speed_y: 0 } }
      let(:service) { described_class.new(ship_id, trajectory, speed) }

      it 'does nothing and keeps status as safe' do
        expect { service.recognize_status }.not_to change { service.status }.from(StatusService::STATUSES[:safe])
      end
    end

    context 'when ship is moving but no other trajectories present' do
      let(:speed) { { main_speed: 3, speed_x: 1, speed_y: 1 } }
      let(:service) { described_class.new(ship_id, trajectory, speed) }

      before do
        allow_any_instance_of(TrajectoryCacheService).to receive(:get_trajectory).with(trajectory_key).and_return([])
      end

      it 'saves current version and keeps status as safe' do
        expect_any_instance_of(TrajectoryCacheService)
          .to receive(:save_version)
                .with("ship:#{ship_id}", anything)

        service.recognize_status
        expect(service.status).to eq(StatusService::STATUSES[:safe])
      end
    end

    context 'when another ship is too close (collision danger)' do
      let(:speed) { { main_speed: 5, speed_x: 0, speed_y: 0 } }
      let(:other_ship) { { ship_id: 2, x: 5, y: 5, version: 'old' } }
      let(:service) { described_class.new(ship_id, trajectory, speed) }

      before do
        # Collision candidate present exactly at same point -> distance = -1 < safe
        json_data = other_ship.to_json
        allow_any_instance_of(TrajectoryCacheService).to receive(:get_trajectory).with(trajectory_key).and_return([json_data])
        allow_any_instance_of(TrajectoryCacheService).to receive(:version).with("ship:2").and_return(nil)
      end

      it 'updates status to danger' do
        service.recognize_status
        expect(service.status).to eq(StatusService::STATUSES[:danger])
      end
    end

    context 'when another ship is at warn distance' do
      let(:speed) { { main_speed: 5, speed_x: 0, speed_y: 0 } }
      let(:other_ship) do
        # dx = 2, dy = 0 => max=2 -> distance = 2-1 = 1 => warn
        { ship_id: 3, x: 7, y: 5, version: 'old' }
      end
      let(:service) { described_class.new(ship_id, trajectory, speed) }

      before do
        json_data = other_ship.to_json
        allow_any_instance_of(TrajectoryCacheService).to receive(:get_trajectory).with(trajectory_key).and_return([json_data])
        allow_any_instance_of(TrajectoryCacheService).to receive(:version).with("ship:3").and_return(nil)
      end

      it 'updates status to warn' do
        service.recognize_status
        expect(service.status).to eq(StatusService::STATUSES[:warn])
      end
    end
  end
end
