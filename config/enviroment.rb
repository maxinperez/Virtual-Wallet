require_relative '../helpers/app_helpers'

require_relative '../models/user'
require_relative '../models/account'
require_relative '../models/bankaccount'
require_relative '../models/card'
require_relative '../models/transaction'
require_relative '../models/message'

module AppConfig
  def self.registered(app)
    app.enable :sessions
    app.set :database, adapter: 'sqlite3', database: 'db/development.sqlite3'
    app.use Rack::MethodOverride
    app.set :views, File.expand_path('../../views', __FILE__)
    app.set :public_folder, File.expand_path('../../public', __FILE__)


    ActiveRecord::Base.logger = Logger.new(STDOUT) if app.development?

    app.configure :development do
      app.enable :logging
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      app.set :logger, logger

      app.register Sinatra::Reloader
      app.after_reload do
      logger.info 'Reloaded!!!'
      end
    end
    app.helpers AppHelpers
  end
end