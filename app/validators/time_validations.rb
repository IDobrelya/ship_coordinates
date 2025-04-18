module TimeValidations
  extend ActiveSupport::Concern

  included do
    validates :time, presence: true
    validate :timestamp_validation
  end

  def timestamp_validation
    validate_not_in_future
    validate_greater_than_previous
  end

  private

  def validate_not_in_future
    return unless time.present?
    errors.add(:time, "can't be in future") if future_time?
  end

  def validate_greater_than_previous
    return if previous_time.blank? || time.blank?
    errors.add(:time, 'should be greater than the previous one') if not_greater_than_previous?
  end

  def future_time?
    time > Time.now.to_i
  end

  def not_greater_than_previous?
    time <= previous_time
  end
end