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
  # Set the start date to 1 hour ago (3600) if the param is nil or empty
  @start_date = params[:start_date].to_s != "" ? params[:start_date] : (DateTime.now.to_time - 3600).to_datetime.strftime("%FT%R")
  # Set the end date to now if the param is nil or empty
  @end_date = params[:end_date].to_s != "" ? params[:end_date] : DateTime.now.strftime("%FT%R")
  @command = CommandRange.new(@start_date, @end_date)

  @processes, @error = @command.exec

  # Render the view
  erb :index
end
