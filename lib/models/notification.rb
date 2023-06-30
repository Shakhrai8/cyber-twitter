class Notification
  attr_accessor :id, :event_type, :peep_id, :user_id, :content

  def initialize(id:, event_type:, peep_id:, user_id:, content:)
    @id = id
    @event_type = event_type
    @peep_id = peep_id
    @user_id = user_id
    @content = content
  end
end