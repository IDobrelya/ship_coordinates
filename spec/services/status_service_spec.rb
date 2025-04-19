require 'rails_helper'
require 'pry'

RSpec.describe StatusService, type: :service do
  let(:ship_id) { 'e7cf9554-f13c-449a-ad31-106ef2b1f762' }
  let(:other_ship_id) { '8d31c7ca-46e5-4e77-9a71-ac6f8b179478' }
  let(:current_time) { 1745056322 }
  let(:trajectory_key) { "future:grid:#{current_time}:0:0" }
  let(:own_trajectory_data) do
    { ship_id: ship_id, x: 5, y: 5, version: current_time }
  end
  let(:own_trajectory) { { trajectory_key => [own_trajectory_data] } }

  before do
    # Stub TrajectoryCacheService methods
    allow_any_instance_of(TrajectoryCacheService).to receive(:save_version)
    allow_any_instance_of(TrajectoryCacheService).to receive(:version).and_return(nil)
  end

  describe '#recognize_status' do
    context 'when ship is not moving' do
      let(:speed) { { main_speed: 0, speed_x: 0, speed_y: 0 } }
      let(:service) { described_class.new(ship_id, own_trajectory, speed) }

      it 'does nothing and keeps status as safe' do
        expect { service.recognize_status }.not_to change { service.status }.from(StatusService::STATUSES[:safe])
      end
    end

    context 'when ship is moving but no other trajectories present' do
      let(:speed) { { main_speed: 3, speed_x: 1, speed_y: 1 } }
      let(:service) { described_class.new(ship_id, own_trajectory, speed) }

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
      let(:speed) { { main_speed: 5, speed_x: 10, speed_y: 3 } }
      let(:service) { described_class.new(ship_id, own_trajectory, speed) }
      let(:other_ship) { { ship_id: other_ship_id, x: 5, y: 5, version: current_time } }

      before do
        json_data = other_ship.to_json
        allow_any_instance_of(TrajectoryCacheService).to receive(:get_trajectory).with(trajectory_key).and_return([json_data])
        allow_any_instance_of(TrajectoryCacheService).to receive(:version).with("ship:#{other_ship_id}").and_return(current_time)
      end

      it 'updates status to danger' do
        service.recognize_status
        expect(service.status).to eq(StatusService::STATUSES[:danger])
      end
    end

    context 'when another ship is at warn distance' do
      let(:speed) { { main_speed: 5, speed_x: 1, speed_y: 1 } }
      let(:other_ship) do
        { ship_id: other_ship_id, x: 5, y: 4, version: current_time }
      end
      let(:service) { described_class.new(ship_id, own_trajectory, speed) }

      before do
        json_data = other_ship.to_json
        allow_any_instance_of(TrajectoryCacheService).to receive(:get_trajectory).with(trajectory_key).and_return([json_data])
        allow_any_instance_of(TrajectoryCacheService).to receive(:version).with("ship:#{other_ship_id}").and_return(current_time)
      end

      it 'updates status to warn' do
        service.recognize_status
        expect(service.status).to eq(StatusService::STATUSES[:warn])
      end
    end

    context 'when we have two ships in one grid and one of them is too close(danger) another one is at warn distance' do
      let(:speed) { { main_speed: 5, speed_x: 1, speed_y: 1 } }
      let(:ship_two_id) { '17a9f19f-7b6b-4611-b90e-2b61f5365ca2' }
      let(:ship_one) do
        { ship_id: other_ship_id, x: 5, y: 4, version: current_time }
      end
      let(:ship_two) do
        { ship_id: ship_two_id, x: 5, y: 5, version: current_time }
      end
      let(:service) { described_class.new(ship_id, own_trajectory, speed) }

      before do
        ship_one_json = ship_one.to_json
        ship_two_json = ship_two.to_json
        allow_any_instance_of(TrajectoryCacheService).to receive(:get_trajectory)
                                                           .with(trajectory_key)
                                                           .and_return([ship_one_json, ship_two_json])
        allow_any_instance_of(TrajectoryCacheService).to receive(:version).with("ship:#{other_ship_id}").and_return(current_time)
        allow_any_instance_of(TrajectoryCacheService).to receive(:version).with("ship:#{ship_two_id}").and_return(current_time)
      end

      it 'updates status to warn' do
        service.recognize_status
        expect(service.status).to eq(StatusService::STATUSES[:danger])
      end
    end
  end
end
