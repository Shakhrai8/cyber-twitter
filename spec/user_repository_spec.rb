require_relative '../lib/repositories/user_repository'
require_relative 'database_helper'

RSpec.describe UserRepository do
  before(:each) do 
    reset_chitter_table
  end

  context '.create' do
    it 'creates a new user in the database' do
      UserRepository.create('John Doe', 'johndoe', 'johndoe@example.com', 'password123')
      user = UserRepository.find_by_email('johndoe@example.com')
    
      expect(user.name).to eq('John Doe')
      expect(user.username).to eq('johndoe')
      expect(user.email).to eq('johndoe@example.com')
      expect(BCrypt::Password.new(user.password) == 'password123').to be_truthy
    end    
  end

  context '.find_by_email' do
    it 'returns the user with the given email' do
      UserRepository.create('Test User 3', 'testuser3', 'testuser3@example.com', 'password123')
      user = UserRepository.find_by_email('testuser3@example.com')

      expect(user).not_to be_nil
      expect(user.name).to eq('Test User 3')
      expect(user.username).to eq('testuser3')
      expect(user.email).to eq('testuser3@example.com')
      expect(BCrypt::Password.new(user.password) == 'password123').to be_truthy
    end

    it 'returns nil if no user found with the given email' do
      user = UserRepository.find_by_email('nonexistent@example.com')

      expect(user).to be_nil
    end
  end

  context '.authenticate' do
    it 'returns the user if the email and password match' do
      UserRepository.create('Test User 4', 'testuser4', 'testuser4@example.com', 'password456')
      user = UserRepository.authenticate('testuser4@example.com', 'password456')

      expect(user).not_to be_nil
      expect(user.name).to eq('Test User 4')
      expect(user.username).to eq('testuser4')
      expect(user.email).to eq('testuser4@example.com')
      expect(BCrypt::Password.new(user.password) == 'password456').to be_truthy
    end

    it 'returns nil if the email and password do not match' do
      UserRepository.create('Test User 5', 'testuser5', 'testuser5@example.com', 'password456')
      user = UserRepository.authenticate('testuser5@example.com', 'incorrect_password')

      expect(user).to be(nil)
    end
  end

  context '.all' do
    it 'returns all users from the database' do
      UserRepository.create('Test User 6', 'testuser6', 'testuser6@example.com', 'password123')
      UserRepository.create('Test User 7', 'testuser7', 'testuser7@example.com', 'password456')
      users = UserRepository.all
    
      expect(users.length).to eq(4)
    
      expect(users[2].name).to eq('Test User 6')
      expect(users[2].username).to eq('testuser6')
      expect(users[2].email).to eq('testuser6@example.com')
      expect(BCrypt::Password.new(users[2].password) == 'password123').to be_truthy
    
      expect(users[3].name).to eq('Test User 7')
      expect(users[3].username).to eq('testuser7')
      expect(users[3].email).to eq('testuser7@example.com')
      expect(BCrypt::Password.new(users[3].password) == 'password456').to be_truthy
    end    
  end

  context '.find' do
    it 'returns the user by id' do
      UserRepository.create('Alice', 'alice01', 'alice@example.com', 'passalice')
      user_by_email = UserRepository.find_by_email('alice@example.com')
      user_by_id = UserRepository.find(user_by_email.id)
  
      expect(user_by_id.name).to eq('Alice')
      expect(user_by_id.username).to eq('alice01')
      expect(user_by_id.email).to eq('alice@example.com')
      expect(BCrypt::Password.new(user_by_id.password) == 'passalice').to be_truthy
    end
  
    it 'returns nil if no user found with the given id' do
      user = UserRepository.find(9999) # assuming this ID does not exist in the test database
  
      expect(user).to be_nil
    end
  end
  
  context '.find_by_username' do
    it 'returns the user with the given username' do
      UserRepository.create('Bob', 'bob01', 'bob@example.com', 'passbob')
      user = UserRepository.find_by_username('bob01')
  
      expect(user.name).to eq('Bob')
      expect(user.email).to eq('bob@example.com')
      expect(BCrypt::Password.new(user.password) == 'passbob').to be_truthy
    end
  
    it 'returns nil if no user found with the given username' do
      user = UserRepository.find_by_username('nonexistent_username')
  
      expect(user).to be_nil
    end
  end
  
  context '.update_photo' do
    it 'updates the user profile photo URL' do
      UserRepository.create('Charlie', 'charlie01', 'charlie@example.com', 'passcharlie')
      user = UserRepository.find_by_email('charlie@example.com')
      UserRepository.update_photo(user.id, 'https://newphoto.url')
  
      updated_user = UserRepository.find_by_email('charlie@example.com')
      expect(updated_user.profile_photo_url).to eq('https://newphoto.url')
    end
  end
  
  context '.update_bio' do
    it 'updates the user bio' do
      UserRepository.create('David', 'david01', 'david@example.com', 'passdavid')
      user = UserRepository.find_by_email('david@example.com')
      UserRepository.update_bio(user.id, 'Updated Bio for David')
  
      updated_user = UserRepository.find_by_email('david@example.com')
      expect(updated_user.bio).to eq('Updated Bio for David')
    end
  end
  
end
