require 'bundler/setup'
require 'sinatra/base'
require 'sqlite3'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require 'logger'
require_relative 'models/user'
require_relative 'models/login'

class App < Sinatra::Application
  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'
  configure :development do
    enable :logging
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger

    register Sinatra::Reloader
    after_reload do
      logger.info 'Reloaded!!!'
    end
  end
  helpers do 
  def partial(template, locals = {})
    erb(:"partial/#{template}", locals: locals)
    end
  end
  get '/login' do 
    erb :login
  end 

  get '/index' do 
    @active_page = 'dashboard'
    @transactions = [
  { icon: "A", name: "Amazon", type: "Compra Online", amount: "-$129.99", amount_class: "amount-negative", date: "12 May, 13:45" },
  { icon: "P", name: "Pago Luz", type: "Pago Servicio", amount: "-$50.00", amount_class: "amount-negative", date: "10 May, 11:20" }]
   erb :index, layout: :'partial/layout'
  end 
  get '/pay' do 
    @active_page = 'pay'
   erb :pay, layout: :'partial/layout'
  end 
  get '/transfer' do 
    @active_page = 'transfer'
   erb :transfer, layout: :'partial/layout'
  end 
  get '/register' do
    erb :register
   end

   get '/add_person' do
    u = User.new(dni: 12345678)
    if u.save
      'Insercion correcta'
    else
      'Error'
   end 
  end 

  post '/register' do
    params.each do |key, value|
      instance_variable_set("@#{key}", value) # crea instancias locales del siguiente formato -> dni = params[:dni]
    end
  "Registro procesado para DNI: #{@dni} y Email: #{@email}"
  end

   get '/verificar_dni' do
    content_type :json
    dni = params[:dni]
    existe = User.exists?(dni: dni)
    { existe: existe }.to_json
  end
 
end