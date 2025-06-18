module AppConfig
  def self.registered(app)
    app.enable :sessions
    app.set :database, adapter: 'sqlite3', database: 'db/development.sqlite3'
    app.use Rack::MethodOverride
    app.set :views, File.dirname(__FILE__) + '/../views'
    app.set :public_folder, File.dirname(__FILE__) + '/../public'

    ActiveRecord::Base.logger = Logger.new(STDOUT) if app.development?

    app.configure :development do
      app.enable :logging
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      app.set :logger, logger

      app.register Sinatra::Reloader
      app.after_reload do
      logger.info 'Reloaded!!!'

    app.helpers AppHelpers
  end
end
