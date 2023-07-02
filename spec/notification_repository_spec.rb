require_relative '../lib/repositories/notification_repository'
require_relative 'database_helper'

RSpec.describe NotificationRepository do
  before(:each) do 
    reset_chitter_table
  end

  context '.create' do
    it 'creates a new notification in the database' do
      event_type = 'New Message'
      peep_id = 1
      user_id = 2
      content = 'This is a new notification'

      expect(DatabaseConnection).to receive(:exec_params) do |query, params|
        expect(query).to include('INSERT INTO notifications (event_type, peep_id, user_id, content) VALUES')
        expect(params[0]).to eq(event_type)
        expect(params[1]).to eq(peep_id)
        expect(params[2]).to eq(user_id)
        expect(params[3]).to eq(content)
      end.and_return([{'id' => '1'}])

      NotificationRepository.create(event_type, peep_id, user_id, content)
    end
  end

  context '.find_by_user' do
    it 'returns notifications for the specified user' do
      user_id = 2
      query_result = [{ 'id' => 1, 'event_type' => 'New Message', 'peep_id' => 1, 'user_id' => 2, 'content' => 'This is a new notification', 'timestamp' => '2023-07-01 12:34:56' }]

      expect(DatabaseConnection).to receive(:exec_params)
        .with('SELECT id, event_type, peep_id, user_id, content, timestamp::timestamp(0) AS timestamp FROM notifications WHERE user_id = $1;', [user_id])
        .and_return(query_result)

      results = NotificationRepository.find_by_user(user_id)

      expect(results).to be_a(Array)
      expect(results.length).to eq(1)
      expect(results[0]).to be_a(Notification)
      expect(results[0].id).to eq(1)
      expect(results[0].event_type).to eq('New Message')
      expect(results[0].peep_id).to eq(1)
      expect(results[0].user_id).to eq(2)
      expect(results[0].content).to eq('This is a new notification')
      expect(results[0].timestamp).to eq('2023-07-01 12:34:56')
    end
  end

  context '.all' do
    it 'returns all notifications in the database' do
      query_result = [
        { 'id' => 1, 'event_type' => 'New Message', 'peep_id' => 1, 'user_id' => 2, 'content' => 'This is a new notification', 'timestamp' => '2023-07-01 12:34:56' },
        { 'id' => 2, 'event_type' => 'New Peep', 'peep_id' => 2, 'user_id' => 3, 'content' => 'This is another new notification', 'timestamp' => '2023-07-01 12:35:00' }
      ]

      expect(DatabaseConnection).to receive(:exec_params)
        .with('SELECT id, event_type, peep_id, user_id, content, timestamp::timestamp(0) AS timestamp FROM notifications;', [])
        .and_return(query_result)

      results = NotificationRepository.all

      expect(results.length).to eq(2)

      expect(results[0]).to be_a(Notification)
      expect(results[0].id).to eq(1)
      expect(results[0].event_type).to eq('New Message')
      expect(results[0].peep_id).to eq(1)
      expect(results[0].user_id).to eq(2)
      expect(results[0].content).to eq('This is a new notification')
      expect(results[0].timestamp).to eq('2023-07-01 12:34:56')

      expect(results[1]).to be_a(Notification)
      expect(results[1].id).to eq(2)
      expect(results[1].event_type).to eq('New Peep')
      expect(results[1].peep_id).to eq(2)
      expect(results[1].user_id).to eq(3)
      expect(results[1].content).to eq('This is another new notification')
      expect(results[1].timestamp).to eq('2023-07-01 12:35:00')
    end
  end

  context '.delete' do
    it 'deletes the specified notification' do
      notification_id = 1
      NotificationRepository.create('New Message', 1, 2, 'This is a new notification')

      expect(NotificationRepository.all.map(&:id)).to include(notification_id)

      NotificationRepository.delete(notification_id)

      expect(NotificationRepository.all.map(&:id)).not_to include(notification_id)
    end
  end
end