require 'rails_helper'

class DummyModel
  include ActiveModel::Model
  include ActiveModel::Validations
  include TimeValidations

  attr_accessor :position, :time, :previous_time
end

RSpec.describe TimeValidations, type: :model do
  subject { DummyModel.new(time: time, previous_time: previous_time, position: { 'x' => 100, 'y' => 200 } ) }

  context 'when time is nil' do
    let(:time) { nil }
    let(:previous_time) { nil }

    it 'is not valid and adds presence error' do
      expect(subject).not_to be_valid
      expect(subject.errors[:time]).to include("can't be blank")
    end
  end

  context 'when time is in the future' do
    let(:time) { Time.now.to_i + 100 } # future
    let(:previous_time) { Time.now.to_i - 100 }

    it 'is not valid and adds future error' do
      expect(subject).not_to be_valid
      expect(subject.errors[:time]).to include("can't be in future")
    end
  end

  context 'when time is not greater than previous_time' do
    let(:time) { 1_000 }
    let(:previous_time) { 2_000 }

    it 'is not valid and adds greater-than error' do
      expect(subject).not_to be_valid
      expect(subject.errors[:time]).to include('should be greater than the previous one')
    end
  end

  context 'when time is valid and greater than previous_time' do
    let(:time) { Time.now.to_i }
    let(:previous_time) { Time.now.to_i - 10 }

    it 'is valid' do
      expect(subject).to be_valid
    end
  end
end