require_relative '../models/notification'

class NotificationRepository
  def self.create(event_type, peep_id, user_id, content)
    query = "INSERT INTO notifications (event_type, peep_id, user_id, content) VALUES ($1, $2, $3, $4) RETURNING id;"
    result = DatabaseConnection.exec_params(query, [event_type, peep_id, user_id, content])
    result[0]['id'].to_i
  end

  def self.find_by_user(user_id)
    query = "SELECT * FROM notifications WHERE user_id = $1;"
    result = DatabaseConnection.exec_params(query, [user_id])
    build_notifications(result)
  end

  def self.delete(notification_id)
    query = "DELETE FROM notifications WHERE id = $1;"
    DatabaseConnection.exec_params(query, [notification_id])
    nil
  end

  private

  def self.build_notification(inst)
    return nil if inst.nil?

    Notification.new(
      id: inst['id'].to_i,
      event_type: inst['event_type'],
      peep_id: inst['peep_id'].to_i,
      user_id: inst['user_id'].to_i,
      content: inst['content']
    )
  end

  def self.build_notifications(results)
    notifications = []
    results.each do |result|
      notifications << build_notification(result)
    end
    notifications
  end
end