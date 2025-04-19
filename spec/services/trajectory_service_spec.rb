require 'rails_helper'
require 'rails_helper'
require 'pry'

RSpec.describe TrajectoryService, type: :service do
  let(:ship_id) { '0df66a6b-6244-4e22-9aca-1052c31769a8' }
  let(:position) { double('Position', position: { 'x' => 150, 'y' => 250 }, time: nil) }
  let(:start_time) { Time.now.to_i }

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
      let(:current_time) { Time.now.to_i }
      let(:speed) { { main_speed: 5, speed_x: 2, speed_y: -1 } }
      let(:service) { described_class.new(ship_id, position, speed, start_time) }

      before { service.calculate_trajectory }

      it 'populates trajectory with DEFAULT_TRAJECTORY_STEPS keys' do
        expect(service.trajectory.keys.size).to eq(TrajectoryService::DEFAULT_TRAJECTORY_STEPS)
      end

      it 'generates sequential keys for different t values without overlap' do
        key1 = service.trajectory.keys.first
        key2 = service.trajectory.keys.last

        expect(key1).not_to eq(key2)
        expect(service.trajectory[key1].first[:version]).to eq(start_time.to_s)
        expect(service.trajectory[key2].first[:version]).to eq(start_time.to_s)
      end

      context 'ship has a linear trajectory' do
        let(:position) { double('Position', position: { 'x' => 100, 'y' => 100 }, time: current_time) }

        context 'ship has linear trajectory by x' do
          let(:speed) { { main_speed: 5, speed_x: 10, speed_y: 0 } }
          let(:time_interval) { 15 }

          let(:calculated) do
            TestHelpers::TrajectoryCalculator.calculate_future_position(
              position,
              speed,
              time_interval
            )
          end

          it "check coordinates in 15 seconds" do
            future_time, grid_x, grid_y, future_x, future_y = calculated.values_at(:future_time, :grid_x, :grid_y,
                                                                                   :future_x, :future_y)

            key = "future:grid:#{future_time}:#{grid_x}:#{grid_y}"
            trajectory_key = service.trajectory.keys[time_interval - 1]
            expect(key).to eq(trajectory_key)

            trajectory_value = service.trajectory[key]
            expect(trajectory_value).to be_a(Array)
            expect(trajectory_value.size).to eq(1)

            ship_data = trajectory_value.first
            expect(ship_data[:x]).to eq(future_x)
            expect(ship_data[:y]).to eq(future_y)
            expect(ship_data[:version]).to eq(current_time.to_s)
          end
        end

        context 'ship has linear trajectory by y' do
          let(:speed) { { main_speed: 5, speed_x: 0, speed_y: 83 } }
          let(:time_interval) { 48 }

          let(:calculated) do
            TestHelpers::TrajectoryCalculator.calculate_future_position(
              position,
              speed,
              time_interval
            )
          end

          it "check coordinates in 48 seconds" do
            future_time, grid_x, grid_y, future_x, future_y = calculated.values_at(:future_time, :grid_x, :grid_y,
                                                                                   :future_x, :future_y)

            key = "future:grid:#{future_time}:#{grid_x}:#{grid_y}"
            trajectory_key = service.trajectory.keys[time_interval - 1]
            expect(key).to eq(trajectory_key)

            trajectory_value = service.trajectory[key]
            expect(trajectory_value).to be_a(Array)
            expect(trajectory_value.size).to eq(1)

            ship_data = trajectory_value.first
            expect(ship_data[:x]).to eq(future_x)
            expect(ship_data[:y]).to eq(future_y)
            expect(ship_data[:version]).to eq(current_time.to_s)
          end
        end
      end

      context 'ship has a diagonal trajectory' do
        let(:position) { double('Position', position: { 'x' => 110, 'y' => 800 }, time: current_time) }
        let(:speed) { { main_speed: 4, speed_x: 3, speed_y: 1 } }
        let(:time_interval) { 30 }
        let(:calculated) do
          TestHelpers::TrajectoryCalculator.calculate_future_position(
            position,
            speed,
            time_interval
          )
        end

        it "check coordinates in 40 seconds" do
          future_time, grid_x, grid_y, future_x, future_y = calculated.values_at(:future_time, :grid_x, :grid_y,
                                                                                 :future_x, :future_y)

          key = "future:grid:#{future_time}:#{grid_x}:#{grid_y}"
          trajectory_key = service.trajectory.keys[time_interval - 1]
          expect(key).to eq(trajectory_key)

          trajectory_value = service.trajectory[key]
          expect(trajectory_value).to be_a(Array)
          expect(trajectory_value.size).to eq(1)

          ship_data = trajectory_value.first
          expect(ship_data[:x]).to eq(future_x)
          expect(ship_data[:y]).to eq(future_y)
          expect(ship_data[:version]).to eq(current_time.to_s)
        end
      end
    end
   end
end
