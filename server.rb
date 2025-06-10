require 'bundler/setup'
require 'sinatra/base'
require 'sqlite3'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require 'logger'

class App < Sinatra::Application
  enable :sessions
  set :database, adapter: 'sqlite3', database: 'db/development.sqlite3'
  ActiveRecord::Base.logger = Logger.new(STDOUT) if development?
  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

#buena practica
require_relative 'models/user'
require_relative 'models/bankaccount'
require_relative 'models/account'
require_relative 'models/transaction'

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
    def current_user
      @current_user ||= User.find_by(dni: session[:dni]) if session[:dni]
    end
    def active_page
      @active_page ||= request.path_info
    end
    def dark_mode?
    session[:dark_mode] || false
  end
  end
  get '/toggle_theme' do
  session[:dark_mode] = !session[:dark_mode]
  redirect back
end

  get '/register' do 
    erb :register, layout: :'partial/header'
  end 

  post '/register' do 
    dni = params[:dni]
    email = params[:email]
    password = params[:password]
    name = params[:name]
    last_name = params[:last_name]
    phone = params[:phone]
    locality = params[:locality]
    cp = params[:cp]
    address = params[:address]

  if User.exists?(dni: dni)
    halt 409, "El DNI ya está registrado"
  end
  if dni.length < 8
    halt 409, "Dni invalido"
  end

  if User.exists?(email: email)
    halt 409, "El correo ya está registrado"
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
      Account.create(user: user, username: dni, password: password)
      BankAccount.create(user: user)
      "Usuario creado correctamente. Por favor, iniciá sesión."
      redirect '/login'
    else 
      puts "Error al registrar el usuario"
      redirect '/register'
    end 
  end

  get '/verificar_dni' do
    content_type :json
    dni = params[:dni]
    existe = User.exists?(dni: dni)
    { existe: existe }.to_json
  end

 get '/' do
   erb :main, layout: :'partial/header'
 end 

  get '/login' do  
     erb :login, layout: :'partial/header'
  end 

  get '/logout' do 
    session.clear
    redirect '/login'
  end 

  get '/personal_data/' do
      erb :personal_data, layout: :'partial/layout'
    end


  post '/login' do 
    dni = params[:dni]
    password = params[:password]
    existing_user = Account.find_by(username: dni)
    if existing_user && existing_user.authenticate(password)
      session[:dni] = params[:dni]
      redirect '/index'
    else 
      session[:error] = 'Datos invalidos'
      puts 'invalid data'
      redirect '/login'
    end
  end

  get '/index' do 
    user = User.find_by(dni: session[:dni])
    if(user&.bank_account)
      @transactions = user.bank_account.most_recent_transactions
    else 
      @transactions = []
    end
   erb :index, layout: :'partial/layout'
  end 

  get '/pay' do 
    erb :pay, layout: :'partial/layout'
  end 

  get '/transfer' do 
   erb :transfer, layout: :'partial/layout'
  end 

  get '/transactions' do
    if current_user && current_user.bank_account
      @transactions = current_user.bank_account.all_transactions.order(created_at: :desc)
    else
      @transactions = []
    end
  erb :transactions, layout: :'partial/layout'
  end

  before do
    protected_paths = ['/index', '/pay', '/transfer', '/transactions']
    if protected_paths.include?(request.path_info) && !session[:dni] # request.path_info solo devuelve la ruta sin la query
      redirect '/login'
    end
  end

  before ['/login', '/register'] do
    redirect '/index' if session[:dni]
  end
end