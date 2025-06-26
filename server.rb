require 'bundler/setup'
require 'sinatra/base'
require 'sqlite3'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require 'logger'
require 'net/http'
require 'json'
require 'prawn'
require_relative 'config/enviroment'
require_relative 'routes/auth'
require_relative 'routes/admin'
require_relative 'routes/user'
require_relative 'routes/transfer'
require_relative 'routes/general'
class App < Sinatra::Application
  register AppConfig
  use AuthRoutes
  use AdminRoutes
  use UserRoutes
  use TransferRoutes
  use GeneralRoutes
end