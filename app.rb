require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'lib/database_connection'
require_relative 'routes/users'
require_relative 'routes/feed'
require 'securerandom'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/repositories/user_repository'
    also_reload 'lib/repositories/tag_repository'
    also_reload 'lib/repositories/peep_tag_repository'
    also_reload 'lib/repositories/peep_repository'
    also_reload 'lib/repositories/reply_repository'
  end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  use Users
  use Feed

  get '/' do
    erb :index
  end
end
