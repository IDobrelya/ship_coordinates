require 'rails_helper'

RSpec.describe SpeedService, type: :service do
  let(:default_values) { described_class::DEFAULT_SPEED_VALUES }

  describe '#current_speed' do
    context 'when previous_position is nil' do
      let(:current_position) { double('Position', position: { 'x' => 5, 'y' => 10 }, time: 100) }
      let(:service) { described_class.new(current_position) }

      it 'returns nil' do
        expect(service.current_speed).to be_nil
      end

      it 'does not change speed attribute from default' do
        expect { service.current_speed }.not_to change { service.speed }.from(default_values)
      end
    end

    context 'when time difference is zero' do
      let(:coords) { { 'x' => 10, 'y' => 20 } }
      let(:current_position)  { double('Position', position: coords, time: 50) }
      let(:previous_position) { double('Position', position: coords, time: 50) }
      let(:service) { described_class.new(current_position, previous_position) }

      it 'returns default speed values' do
        expect(service.current_speed).to eq(default_values)
      end

      it 'sets speed attribute to default values' do
        service.current_speed
        expect(service.speed).to eq(default_values)
      end
    end

    context 'when previous and current positions differ in space and time' do
      let(:current_position)  { double('Position', position: { 'x' => 30, 'y' => 10 }, time: 15) }
      let(:previous_position) { double('Position', position: { 'x' => 10, 'y' => 10 }, time: 5) }
      let(:service) { described_class.new(current_position, previous_position) }

      it 'calculates correct speeds and updates attribute' do
        result = service.current_speed
        expected = { main_speed: 2, speed_x: 2, speed_y: 0 }

        expect(result).to eq(expected)
        expect(service.speed).to eq(expected)
      end
    end
  end
end
