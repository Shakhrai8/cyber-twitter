require 'sinatra/base'
require_relative '../lib/repositories/user_repository'
require_relative '../lib/repositories/peep_repository'
require_relative '../lib/repositories/notification_repository'

class Users < Sinatra::Base

  get '/signup' do
    erb :signup
  end

  post '/signup' do
    name = sanitize_input(params[:name])
    username = sanitize_input(params[:username])
    email = sanitize_input(params[:email])
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
    email = sanitize_input(params[:email])
    password = sanitize_input(params[:password])
  
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

  def sanitize_input(input)
    Rack::Utils.escape_html(input.strip)
  end
end
