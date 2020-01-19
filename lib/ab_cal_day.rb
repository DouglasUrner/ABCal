class ABCalDay
  attr_reader :date, :reason, :message

  def initialize(date, reason, message)
    @date = date
    @reason = reason
    @message = message
  end
end
