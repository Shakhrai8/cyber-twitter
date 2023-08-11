require 'rspec'
require 'rack/test'
require_relative 'database_helper'
require_relative '../app'

RSpec.describe 'Users' do
  include Rack::Test::Methods

  def app
    Users
  end

  let(:user_params) do
    {
      name: 'John Doe',
      username: 'johndoe',
      email: 'john@example.com',
      password: 'password'
    }
  end

  before(:each) do 
    reset_chitter_table
  end
  
  describe 'POST /signup' do
    it 'creates a new user and sets the session user_id' do
      expect(UserRepository).to receive(:create).with(
        user_params[:name],
        user_params[:username],
        user_params[:email],
        user_params[:password]
      ).and_return('user_id')

      post '/signup', user_params

      expect(last_response).to be_redirect
      expect(last_response.location).to include('/login')
    end

    context 'with invalid inputs' do
      it 'rejects empty name' do
        post '/signup', user_params.merge(name: '')
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/signup')
        # You can further check for the error message in the session, if necessary
      end
  
      it 'rejects empty username' do
        post '/signup', user_params.merge(username: '')
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/signup')
      end
  
      it 'rejects invalid email format' do
        post '/signup', user_params.merge(email: 'invalid_email')
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/signup')
      end
  
      it 'rejects password less than 8 characters' do
        post '/signup', user_params.merge(password: 'short')
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/signup')
      end
    end
  end

  describe 'POST /login' do
    let(:existing_user) { double('User', id: 'user_id') }

    before do
      allow(UserRepository).to receive(:authenticate).and_return(existing_user)
    end

    context 'with valid credentials' do
      it 'sets the session user_id and redirects to profile' do
        post '/login', email: user_params[:email], password: user_params[:password]

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/profile')
        expect(last_request.session[:user_id]).to eq('user_id')
      end
    end

    context 'with invalid credentials' do
      before do
        allow(UserRepository).to receive(:authenticate).and_return(nil)
      end

      it 'redirects to login page' do
        post '/login', email: user_params[:email], password: user_params[:password]

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/login')
        expect(last_request.session[:user_id]).to be_nil
      end
    end
  end

  describe 'GET /profile' do
    context 'when user is logged in' do
      let(:user) do
        UserRepository.create('John Doe', 'johndoe', 'john@example.com', 'password')
        UserRepository.find_by_email('john@example.com')
      end
    
      before do
        allow(UserRepository).to receive(:find).and_return(user)
        allow(PeepRepository).to receive(:find_by_user).and_return([])
      end
    
      it 'renders the profile page' do
        get '/profile', {}, { 'rack.session' => { user_id: user.id } }
    
        expect(last_response).to be_ok
        expect(last_response.body).to include('Profile')
      end

      it 'loads replies and notifications' do
        # Mocking the methods
        allow(ReplyRepository).to receive(:find_by_user).and_return([])
        allow(NotificationRepository).to receive(:find_by_user).and_return([])
  
        get '/profile', {}, { 'rack.session' => { user_id: 'user_id' } }
  
        expect(ReplyRepository).to have_received(:find_by_user)
        expect(NotificationRepository).to have_received(:find_by_user)
      end
    end
    

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get '/profile'
        expect(last_response).to be_redirect
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'POST /update_photo' do
    let(:photo_url) { 'http://example.com/photo.jpg' }
  
    it 'updates the user photo URL' do
      expect(UserRepository).to receive(:update_photo).with('user_id', photo_url)
      post '/update_photo', { photo_url: photo_url }.to_json, { 'rack.session' => { user_id: 'user_id' } }
      expect(last_response.status).to eq(200)
    end
  end
  
  describe 'POST /update_bio' do
    let(:bio) { 'This is a bio.' }
  
    it 'updates the user bio' do
      expect(UserRepository).to receive(:update_bio).with('user_id', bio)
      post '/update_bio', { bio: bio }.to_json, { 'rack.session' => { user_id: 'user_id' } }
      expect(last_response.status).to eq(200)
    end
  end
  
  describe 'POST /profile/dismiss' do
    it 'dismisses the notification' do
      notification_id = 42
      expect(NotificationRepository).to receive(:delete).with(notification_id)
      post '/profile/dismiss', { notification_id: notification_id }, { 'rack.session' => { user_id: 'user_id' } }
      expect(last_response).to be_redirect
      expect(last_response.location).to include('/profile#notification-popup')
    end
  end

  describe 'GET /logout' do
    it 'clears the session and redirects to login page' do
      get '/logout', {}, { 'rack.session' => { user_id: 'user_id' } }

      expect(last_response).to be_redirect
      expect(last_response.location).to include('/')
      expect(last_request.session[:user_id]).to be_nil
    end
  end
end