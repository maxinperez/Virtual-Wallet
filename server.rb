require 'bundler/setup'
require 'sinatra/base'
require 'sqlite3'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require 'logger'
require_relative 'models/user'
require_relative 'models/bankaccount'
require_relative 'models/account'
class App < Sinatra::Application
  enable :sessions
  set :database, adapter: 'sqlite3', database: 'db/development.sqlite3'
  ActiveRecord::Base.logger = Logger.new(STDOUT) if development?
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

  get '/register' do 
    erb :register
  end 

  post '/register' do 
    dni = params[:dni]
    email = params[:email]
    password = params[:password]
    confirm = params[:confirmPassword]
    name = params[:name]
    last_name = params[:last_name]
    phone = params[:phone]
    locality = params[:locality]
    cp = params[:cp]
    address = params[:address]

    if password != confirm 
      return "Las contraseñas no coinciden"
    end

    if User.exists?(dni: dni)
      return "El DNI ya está registrado"
    end 

    if User.exists?(email: email)
      return "El correo ya está registrado"
    end

    user = User.new(
    dni: dni,
    email: email,
    name: name,
    last_name: last_name,
    phone: phone,
    locality: locality,
    cp: cp,
    address: address
    )

    if user.save
      Login.create(dni: dni, password: password)
      Account.create(dni: dni)
      "Usuario creado correctamente. Por favor, iniciá sesión."
      redirect '/login'
    else 
      "Error al registrar el usuario"
      redirect '/register'
    end 
  end

  get '/verificar_dni' do
    content_type :json
    dni = params[:dni]
    existe = User.exists?(dni: dni)
    { existe: existe }.to_json
  end
 

  get '/login' do 
    erb :login
  end 

  post '/login' do 
    dni = params[:dni]
    password = params[:password]

    existing_user = Login.find_by(dni: dni)
    if existing_user && existing_user.authenticate(password)
      session[:dni] = params[:dni]
      redirect '/index'
    else 
      session[:error] = 'Datos invalidos'
      redirect '/login'
    end
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

end