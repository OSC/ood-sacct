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

  # Attempt to parse the client-provided date, if invalid, use the default
  #
  # @param date_string [String] A string that can be parsed into a DateTime object
  # @param default [DateTime] A datetime object to be used as a default time
  def parse_datestring(date_string, default = DateTime.now)
    begin
      date = DateTime.parse(date_string.to_s)
    rescue
      date = default
    end
    date.to_datetime.strftime("%FT%R")
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
  @start_date = parse_datestring(params[:start_date], DateTime.now.to_time - 3600)
  @end_date = parse_datestring(params[:end_date])
  @command = CommandRange.new(@start_date, @end_date)

  @processes, @error = @command.exec

  # Render the view
  erb :index
end
