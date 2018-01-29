require 'erubi'
require './command'
require './command_range'
require 'date'

set :erb, :escape_html => true

if development?
  require 'sinatra/reloader'
  also_reload './command.rb'
end

helpers do
  def dashboard_title
    "Open OnDemand"
  end

  def dashboard_url
    "/pun/sys/dashboard/"
  end

  def title
    "Completed Jobs"
  end
end

get '/show/:id' do
  @id = params[:id]
  @message = "Showing details for #{@id}"
  @command = Command.new(@id)

  @output, @error = @command.exec

  # Render the view
  erb :show
end

# Define a route at the root '/' of the app.
get '/' do
  @start_date = params[:start_date] || Date.today.prev_day(7).to_datetime.strftime("%FT%R")
  @end_date = params[:end_date] || DateTime.now.strftime("%FT%R")
  @command = CommandRange.new(params[:start_date], params[:end_date])

  @processes, @error = @command.exec

  # Render the view
  erb :index
end
