require 'sinatra/base'
require_relative '../lib/repositories/user_repository'
require_relative '../lib/repositories/peep_repository'
require_relative '../lib/repositories/notification_repository'

class Users < Sinatra::Base
  enable :sessions
  set :session_secret, "5cdde102f6f68294e1cff23f341aaaaf2d2725453eaccc8ebc239629e724fc53"

  get '/signup' do
    erb :signup
  end

  post '/signup' do
    name = params[:name].strip
    username = params[:username].strip
    email = params[:email].strip
    password = params[:password]
  
    # Check if name is empty
    if name.empty?
      session[:error] = "Name cannot be empty."
      redirect '/signup'
    end
  
    # Check if username is empty
    if username.empty?
      session[:error] = "Username cannot be empty."
      redirect '/signup'
    end
  
    # Check if email is valid
    if !(email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
      session[:error] = "Please enter a valid email."
      redirect '/signup'
    end
  
    # Check if password is valid (minimum 8 characters)
    if password.length < 8
      session[:error] = "Password must be at least 8 characters long."
      redirect '/signup'
    end
  
    UserRepository.create(name, username, email, password)
    redirect '/login'
  end  

  get '/login' do
    erb :login
  end

  post '/login' do
    email = params[:email]
    password = params[:password]

    user = UserRepository.authenticate(email, password)

    if user
      session[:user_id] = user.id
      redirect '/profile'
    else
      redirect '/login'
    end
  end

  get '/profile' do
    if logged_in?
      @user = current_user
      @peeps = PeepRepository.find_by_user(@user.id)
      @notifications = NotificationRepository.find_by_user(@user.id) 
      erb :profile
    else
      redirect '/login'
    end
  end
  

  get '/logout' do
    session.clear
    redirect '/'
  end

  private

  def logged_in?
    !session[:user_id].nil?
  end

  def current_user
    UserRepository.find(session[:user_id])
  end
end
