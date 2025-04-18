require 'rails_helper'
require 'pry'

RSpec.describe TrajectoryService, type: :service do
  let(:ship_id) { 42 }
  let(:position) { double('Position', position: { 'x' => 5, 'y' => 10 }, time: nil) }
  let(:start_time) { 1_600_000_000 }

  describe '#calculate_trajectory' do
    context 'when ship is not moving (main_speed zero or missing)' do
      let(:speed_zero) { { main_speed: 0, speed_x: 0, speed_y: 0 } }
      let(:service) { described_class.new(ship_id, position, speed_zero, start_time) }

      it 'does not populate trajectory and returns nil' do
        expect(service.calculate_trajectory).to be_nil
        expect(service.trajectory).to be_empty
      end
    end

    context 'when ship is moving' do
      let(:speed) { { main_speed: 5, speed_x: 2, speed_y: -1 } }
      let(:service) { described_class.new(ship_id, position, speed, start_time) }

      before { service.calculate_trajectory }

      it 'populates trajectory with DEFAULT_TRAJECTORY_STEPS keys' do
        expect(service.trajectory.keys.size).to eq(TrajectoryService::DEFAULT_TRAJECTORY_STEPS)
      end

      it 'uses the correct key format and values for t = 1' do
        t = 1
        future_time = start_time + t
        future_x = position.position['x'] + speed[:speed_x] * t
        future_y = position.position['y'] + speed[:speed_y] * t
        grid_x = (future_x.to_f / TrajectoryService::DEFAULT_CELL_SIZE).round
        grid_y = (future_y.to_f / TrajectoryService::DEFAULT_CELL_SIZE).round
        key = "future:grid:#{future_time}:#{grid_x}:#{grid_y}"

        # binding.pry
        expect(service.trajectory).to have_key(key)
        expect(service.trajectory[key]).to contain_exactly(
                                             hash_including(
                                               ship_id: ship_id,
                                               x: future_x.round,
                                               y: future_y.round,
                                               version: start_time.to_s
                                             )
                                           )
      end

      it 'generates sequential keys for different t values without overlap' do
        key1 = service.trajectory.keys.first
        key2 = service.trajectory.keys.last

        expect(key1).not_to eq(key2)
        expect(service.trajectory[key1].first[:version]).to eq(start_time.to_s)
        expect(service.trajectory[key2].first[:version]).to eq(start_time.to_s)
      end
    end
  end
end
