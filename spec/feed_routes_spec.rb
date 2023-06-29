require 'rspec'
require 'rack/test'
require_relative 'database_helper'
require_relative '../app'

RSpec.describe 'Feed' do
  include Rack::Test::Methods

  def app
    Feed
  end

  let(:user_params) do
    {
      name: 'John Doe',
      username: 'johndoe',
      email: 'john@example.com',
      password: 'password'
    }
  end

  let(:peep_params) do
    {
      content: 'Hello, world!',
      user_id: 'user_id'
    }
  end

  before(:each) do
    reset_chitter_table
    UserRepository.create(user_params[:name], user_params[:username], user_params[:email], user_params[:password])
    allow(PeepRepository).to receive(:create)
    allow(ReplyRepository).to receive(:create)
  end

  describe 'GET /feed' do
    context 'when user is logged in' do
      it 'renders the feed page' do
        get '/feed', {}, { 'rack.session' => { user_id: 'user_id' } }

        expect(last_response).to be_ok
        expect(last_response.body).to include('Global Feed')
      end

      it 'displays peeps in reverse chronological order' do
        allow(PeepRepository).to receive(:all).and_return([])
        get '/feed', {}, { 'rack.session' => { user_id: 'user_id' } }

        expect(last_response.body).to include('<div class="create-peep">')
        expect(last_response.body).to include('<h2>Create a Peep</h2>')
        expect(last_response.body).to include('<form action="/create_peep" method="post">')
        expect(last_response.body).to include('<textarea name="content" placeholder="Write your peep here"></textarea>')
        expect(last_response.body).to include('<button type="submit">Peep</button>')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        get '/feed'

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'POST /reply' do
    context 'when user is logged in' do
      it 'creates a new reply and redirects to feed' do
        post '/reply', { content: 'Reply', peep_id: 1 }, { 'rack.session' => { user_id: 'user_id' } }

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/feed')
        expect(ReplyRepository).to have_received(:create).with('Reply', 'user_id', 1)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        post '/reply'

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'POST /create_peep' do
    context 'when user is logged in' do
      it 'creates a new peep and redirects to feed' do
        post '/create_peep', peep_params, { 'rack.session' => { user_id: 'user_id' } }

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/feed')
        expect(PeepRepository).to have_received(:create).with('Hello, world!', 'user_id')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login page' do
        post '/create_peep'

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'GET /user_info/:user_id' do
    context 'when user is logged in' do
      it 'renders the user info page' do
        get '/user_info/1', {}, { 'rack.session' => { user_id: 'user_id' } }

        expect(last_response).to be_ok
        expect(last_response.body).to include('<h3>Test User 1</h3>')
        expect(last_response.body).to include('<p>Username: testuser1</p>')
        expect(last_response.body).to include('<p>Email: testuser1@example.com</p>')
      end
    end
  end
end
