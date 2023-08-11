require_relative '../models/user'
require 'bcrypt'


class UserRepository
  def self.create(name, username, email, password)
    hashed_password = BCrypt::Password.create(password)
    query = "INSERT INTO users (name, username, email, password) VALUES ($1, $2, $3, $4) RETURNING id;"
    result = DatabaseConnection.exec_params(query, [name, username, email, hashed_password])
  

    result[0]['id'].to_i
  rescue PG::UniqueViolation => e
    # Handle unique constraint violations
    if e.message.include?("email")
      return 'duplicate_email'
    elsif e.message.include?("username")
      return 'duplicate_username'
    end
    return nil
  end  

  def self.find(id)
    query = "SELECT * FROM users WHERE id = $1;"
    result = DatabaseConnection.exec_params(query, [id])

    return find_helper(result)
  end

  def self.find_by_email(email)
    query = "SELECT * FROM users WHERE email = $1;"
    result = DatabaseConnection.exec_params(query, [email])
    
    return find_helper(result)
  end

  def self.find_by_username(username)
    query = "SELECT * FROM users WHERE username = $1;"
    result = DatabaseConnection.exec_params(query, [username])
    
    return find_helper(result)
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && BCrypt::Password.new(user.password) == password
      return user
    else
      return nil
    end
  end  

  def self.all
    users = []
    query = "SELECT * FROM users;"
    result = DatabaseConnection.exec_params(query, [])
    result.each do |inst|
      users << all_helper(inst)
    end
    return users
  end

  def self.update_photo(id, photo_url)
    query = "UPDATE users SET profile_photo_url = $1 WHERE id = $2;"
    DatabaseConnection.exec_params(query, [photo_url, id])
  end

  def self.update_bio(id, bio)
    query = "UPDATE users SET bio = $1 WHERE id = $2;"
    DatabaseConnection.exec_params(query, [bio, id])
  end

  private

  def self.all_helper(inst)
    user = User.new
    user.id = inst['id'].to_i
    user.name = inst['name']
    user.username = inst['username']
    user.email = inst['email']
    user.password = inst['password']
    user.profile_photo_url = inst['profile_photo_url']
    user.bio = inst['bio']

    return user
  end

  def self.find_helper(result)
    return nil if result.ntuples.zero?

    inst = result[0]
    user = User.new
    user.id = inst['id'].to_i
    user.name = inst['name']
    user.username = inst['username']
    user.email = inst['email']
    user.password = inst['password']
    user.profile_photo_url = inst['profile_photo_url']
    user.bio = inst['bio']

    return user
  end
end
