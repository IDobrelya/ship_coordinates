require 'rails_helper'

RSpec.describe 'Ship navigation flow', type: :integration do
  let(:cache_double) { instance_double(TrajectoryCacheService).as_null_object }
  let(:first_ship_id) { 'd930902f-9c26-4faa-88ac-30ef1939eb2b' }
  let(:second_ship_id) { 'f69a27dd-0948-431b-a6dd-2fb0efef4107' }
  let(:start_time) { 1745484516 }

  before do
    allow(TrajectoryCacheService).to receive(:new).and_return(cache_double)

    @fake_store = {}
    @fake_positions = {}
    @fake_versions = {}

    allow(cache_double).to receive(:set_position) { |key| @fake_positions[key] = first_ship_id }
    allow(cache_double).to receive(:get_position) { |key| @fake_positions[key] }

    allow(cache_double).to receive(:set_trajectory) do |arg|
      arg.each { |k, v| (@fake_store[k] ||= []).concat(v.map(&:stringify_keys).map(&:to_json)) }
    end
    allow(cache_double).to receive(:get_trajectory) { |key| @fake_store[key] || [] }

    allow(cache_double).to receive(:save_version) { |key| @fake_versions[key] = start_time }
    allow(cache_double).to receive(:version) { |key| @fake_versions[key] }
  end

  context 'First ship is not moving. Second ship are moving and their trajectories is crossing' do
    let(:previous_position)    { double('Position', position: { 'x' => 0,  'y' => 0  },  time: start_time - 10) }
    let(:current_position)     { double('Position', position: { 'x' => 10,  'y' => 0  },  time: start_time    ) }
    let(:other_ship_position)  { double('Position', position: { 'x' => 15,  'y' => 0  },  time: start_time    ) }

    it 'should be dangerous status' do
      dispatcher_service = DispatcherService.new(first_ship_id, other_ship_position, nil, start_time)
      dispatcher_service.call

      dispatcher_service = DispatcherService.new(second_ship_id, current_position, previous_position , start_time)
      dispatcher_service.call

      expect(dispatcher_service.status).to eq(StatusService::STATUSES[:danger])
    end
  end

  context 'first and second ship are moving. Their trajectories are crossing' do
    let(:first_ship) do
      {
        ship_id: first_ship_id,
        previous_position: double('Position', position: { 'x' => 100,  'y' => 100  },  time: start_time - 5),
        current_position: double('Position', position: { 'x' => 105,  'y' => 100  },  time: start_time    )
      }
    end

    let(:second_ship) do
      {
        ship_id: second_ship_id,
        previous_position: double('Position', position: { 'x' => 110,  'y' => 110  },  time: start_time - 5),
        current_position: double('Position', position: { 'x' => 110,  'y' => 105  },  time: start_time    )
      }
    end

    it 'should be dangerous status' do
      f_dispatcher_service = DispatcherService.new(first_ship[:ship_id], first_ship[:current_position], first_ship[:previous_position], start_time)
      f_dispatcher_service.call

      s_dispatcher_service = DispatcherService.new(second_ship[:ship_id], second_ship[:current_position], second_ship[:previous_position], start_time)
      s_dispatcher_service.call

      expect(s_dispatcher_service.status).to eq(StatusService::STATUSES[:danger])
    end
  end
end
