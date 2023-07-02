require 'sinatra/base'
require_relative '../lib/repositories/user_repository'
require_relative '../lib/repositories/peep_repository'
require_relative '../lib/repositories/tag_repository'
require_relative '../lib/repositories/reply_repository'
require_relative '../lib/repositories/peep_tag_repository'
require_relative '../lib/repositories/notification_repository'

class Feed < Sinatra::Base
  # future sort function
  # get '/sort_peeps' do
  #   if logged_in?
  #     @peeps = PeepRepository.all
  #     @user_repo = UserRepository
  #     @tag_repo = TagRepository
  #     @reply_repo = ReplyRepository
  #     @peep_tag_repo = PeepTagRepository
  #     @sorted_peeps = PeepRepository.sort_by_timestamp(@peeps)
  
  #     erb :feed, locals: { peeps: @sorted_peeps }, layout: :'_feed_layout'
  #   else
  #     redirect '/login'
  #   end
  # end
  
  # get '/revert_sorting' do
  #   if logged_in?
  #     @peeps = PeepRepository.all
  #     @user_repo = UserRepository
  #     @tag_repo = TagRepository
  #     @reply_repo = ReplyRepository
  #     @peep_tag_repo = PeepTagRepository.reverse!
  #     erb :feed
  #   else
  #     redirect '/login'
  #   end
  # end
  
  get '/feed' do
    if logged_in?
      @peeps = PeepRepository.all
      @sorted_peeps = PeepRepository.sort_by_timestamp(@peeps).reverse!
      @user_repo = UserRepository
      @tag_repo = TagRepository
      @reply_repo = ReplyRepository
      @peep_tag_repo = PeepTagRepository
      erb :feed
    else
      redirect '/login'
    end
  end

  post '/reply' do
    if logged_in?
      content = sanitize_input(params[:content])
      user_id = session[:user_id]
      peep_id = sanitize_input(params[:peep_id]).to_i
  
      ReplyRepository.create(content, user_id, peep_id)
      by_this_user = UserRepository.find(user_id.to_i)
      mentioned_usernames = user_tags(content)
  
      mentioned_usernames.each do |mentioned_username|
        mentioned_user = UserRepository.find_by_username(mentioned_username)
        if mentioned_user
          NotificationRepository.create("mention", PeepRepository.all.last.id, mentioned_user.id, "You have been mentioned in a peep by the user @#{by_this_user.username}.")
        end
      end

      redirect '/feed'
    else
      redirect '/login'
    end
  end
  
  post '/create_peep' do
    if logged_in?
      content = sanitize_input(params[:content])
      user_id = session[:user_id]
  
      PeepRepository.create(content, user_id)
      by_this_user = UserRepository.find(user_id.to_i)

      tags = sanitize_input(params[:tags]).split(',')
      tags.each do |tag|
        TagRepository.create(tag)
        PeepTagRepository.create(PeepRepository.all.last.id, TagRepository.all.last.id)
      end
  
      mentioned_usernames = user_tags(content)
  
      mentioned_usernames.each do |mentioned_username|
        mentioned_user = UserRepository.find_by_username(mentioned_username)
        if mentioned_user
          NotificationRepository.create("mention", PeepRepository.all.last.id, mentioned_user.id, "You have been mentioned in a peep by the user @#{by_this_user.username}.")
        end
      end
  
      redirect '/feed'
    else
      redirect '/login'
    end
  end

  get '/user_info/:user_id' do
    user_id = params[:user_id].to_i
    user = UserRepository.find(user_id)
    erb :user_info, locals: { user: user }
  end

  private

  def logged_in?
    !session[:user_id].nil?
  end

  def current_user
    UserRepository.find(session[:user_id])
  end

  def user_tags(content)
    tags = content.scan(/@\w+/) 
    usernames = tags.map{ |tag| tag[1..] } 
  end

  def sanitize_input(input)
    Rack::Utils.escape_html(input)
  end
end
