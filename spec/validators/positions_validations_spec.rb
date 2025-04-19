require 'rails_helper'

class DummyModel
  include ActiveModel::Model
  include ActiveModel::Validations
  include PositionValidations

  attr_accessor :position
end

RSpec.describe PositionValidations, type: :model do
  subject { DummyModel.new(position: position, time: Time.now.to_i) }

  context 'when position is nil' do
    let(:position) { nil }

    it 'is not valid and adds error on position' do
      expect(subject).not_to be_valid
      expect(subject.errors[:position]).to include("can't be blank")
    end
  end

  context 'when x and y are missing' do
    let(:position) { {} }

    it 'is not valid and adds errors for x and y presence' do
      expect(subject).not_to be_valid
      expect(subject.errors[:x]).to include('is not present')
      expect(subject.errors[:y]).to include('is not present')
    end
  end

  context 'when x and y are not integers' do
    let(:position) { { 'x' => 'abc', 'y' => 3.14 } }

    it 'is not valid and adds type errors for x and y' do
      expect(subject).not_to be_valid
      expect(subject.errors[:x]).to include('x must be an integer')
      expect(subject.errors[:y]).to include('y must be an integer')
    end
  end

  context 'when only one coordinate is invalid' do
    let(:position) { { 'x' => 10, 'y' => 'wrong' } }

    it 'is not valid and adds error only for y' do
      expect(subject).not_to be_valid
      expect(subject.errors[:y]).to include('y must be an integer')
      expect(subject.errors[:x]).to be_empty
    end
  end

  context 'when x and y are valid integers' do
    let(:position) { { 'x' => 100, 'y' => 200 } }

    it 'is valid' do
      expect(subject).to be_valid
    end
  end
end
