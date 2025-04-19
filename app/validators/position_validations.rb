module PositionValidations
  extend ActiveSupport::Concern

  included do
    validates :position, presence: true
    validate :position_validation
  end

  def position_validation
    x, y = position&.values_at('x', 'y')
    validate_on_presenting(x, y)
    validate_on_type(x, y)
  end

  private

  def validate_on_presenting(x, y)
    errors.add(:x, 'is not present') if x.blank?
    errors.add(:y, 'is not present') if y.blank?
  end

  def validate_on_type(x, y)
    errors.add(:x, 'x must be an integer') if x.present? && !integer?(x)
    errors.add(:y, 'y must be an integer') if y.present? && !integer?(y)
  end

  def integer?(value)
    value.is_a?(Integer)
  end
end