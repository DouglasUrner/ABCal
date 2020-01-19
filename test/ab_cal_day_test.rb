gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/ab_cal_day'

require 'date'

class ABCalDayTest < Minitest::Test
  def test_that_an_ABCalDay_object_requires_3_args
    exception = assert_raises ArgumentError do
      ABCalDay.new()
    end
  end

  def test_that_an_ABCalDay_object_is_created
    date = Date.new()
    reason = 'F'
    message = 'First Day'
    calday = ABCalDay.new(date, reason, message)
    # assert_instance_of ABCalDay, calday
    # assert_equal date, calday.date
    assert_equal date, calday.reason
    assert_equal date, calday.message
  end

  def test_that_ABCalDay_checks_date_argument
    skip
  end

  def test_first_day_is_set
    skip
  end

  def test_first_day_is_an_a_day
    skip
  end

  def test_last_day_is_set
    skip
  end

  def test_ab_days_alternate
    skip
  end

  def test_weekends_are_skipped
    skip
  end

  def test_holidays_are_skipped
    skip
  end

  def test_neutral_days_are_skipped
    skip
  end

  def test_rotation_is_reset_at_semester
    skip
  end

  def test_snow_days_preserve_rotation
    skip
  end

  def test_snow_days_extend_school_year
    skip
  end

  def test_waiver_days_preserve_rotation
    skip
  end

  def test_waiver_days_do_not_extend_school_year
    skip
  end
end
