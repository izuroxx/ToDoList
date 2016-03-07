require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/base'
require 'sinatra/activerecord'
require './environments.rb'
# require 'sinatra/session'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions

helpers do
	def current_user
		session[:user_id] && session[:user_id].length > 0
	end

	def current_user
  		@user = User.find_by(id: session[:user_id])
	end
end


class User < ActiveRecord::Base
	has_many :tasks
	has_secure_password

	validates :login, presence: true, length: { minimum: 6 }, uniqueness: true
	validates :password, presence: true, length: { minimum: 6 }
end


class Task < ActiveRecord::Base
  belongs_to :user
  validates :title, presence: true
end




get '/' do
	erb :main
end

get '/signup' do
	if current_user
		redirect '/', notice: 'You are already signed up!'
	else
	erb :signup
	end
end

post '/create_user' do
	user = User.new(params)
	if current_user
		redirect '/', notice: 'You are already signed up!'
	elsif user.save
		session[:user_id] = user.id
		redirect "/tasks", notice: 'You are now signed up!'

	else
		redirect "/signup", error: user.errors.full_messages
	end
end


get '/login' do
	if current_user
		redirect '/', notice: 'You are already logged in!'
	else
		erb :login
	end
end

post '/login' do
	user = User.find_by(login: params[:login])
	if current_user
		redirect '/', notice: 'You are already logged in!'
	elsif
		user && user.authenticate(params[:password])
		session[:user_id] = user.id
		redirect "/", notice: 'Welcome again!!!'
	else
		redirect "/login", error: "Login or password incorrect. Try again!"
	end
end


get'/logout' do
	if current_user
		session[:user_id] = nil
	  	redirect '/', notice: 'Good bye, you are now logged out...'
	else
		'/'
	end
end


get '/tasks/:id/complete' do
	if current_user
	task = current_user.tasks.find(params[:id])
	task.update(finished: true)
	redirect '/tasks'
	else
	redirect '/login', notice: 'You are not logged in!!!'
	end
end
get '/tasks/finished' do
	if current_user
  	@tasks = current_user.tasks.where(finished: true)
  	erb :tasks
  else
  	redirect '/login', notice: 'You are not logged in!!!!!'
	end
end


get '/tasks/in_progress' do
	if current_user
		@tasks = current_user.tasks.where(finished: false)
  		erb :tasks
	else 
		redirect '/login', notice: 'You are not logged in!!!'
	end
end

get '/tasks/new' do
	if current_user
	 	erb :new_task
	else
		redirect 'login', notice: 'You are not logged in!!!' 
	end
end


post '/create_task' do
	task = current_user.tasks.new(params)
	if task.save
		redirect '/tasks', notice: 'Task added!'
	else
		redirect '/tasks/new', error: task.errors.full_messages
	end

end

delete '/tasks/:id' do
	if current_user
  		task = current_user.tasks.find(params[:id])
  		task.destroy
  		redirect '/tasks', notice: 'Task deleted!'
  	else
  		redirect '/', notice: 'You are not logged in!!!'
  	end
end
 
get '/tasks' do
	if current_user
		@tasks = current_user.tasks.all
		erb :tasks
	else
		redirect '/', notice: 'You are not logged in!!!'
	end
end

            
get '/tasks/:id/edit' do
	if current_user
		@task=current_user.tasks.find(params[:id])
		erb :edit_task
	else
		redirect '/', notice: 'You are not logged in!!!'
	end
end


put '/tasks/:id' do
	if current_user
		task = current_user.tasks.find(params[:id])
	
		if task.update(params[:task])
			redirect '/tasks', notice: 'Task updated!'
		else
			redirect "/tasks/#{task.id}/edit", error: task.errors.full_messages
		end
	else
		redirect '/', notice: 'You are not logged in!!!'
	end	
end


get '/tasks/:id' do
	if current_user 
	@task = current_user.tasks.find(params[:id]) 
	erb :task
	else
		redirect '/', notice: 'You are not logged in!!!'
	end
end




