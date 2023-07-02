class Notification
  attr_accessor :id, :event_type, :peep_id, :user_id, :content, :timestamp

  def initialize(id:, event_type:, peep_id:, user_id:, content:, timestamp:)
    @id = id
    @event_type = event_type
    @peep_id = peep_id
    @user_id = user_id
    @content = content
    @timestamp = timestamp
  end
end