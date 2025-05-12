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
  dni = params[:dni]
  email = params[:email]
  password = params[:password] 
  confirmPassword = params[:confirmPassword]
  nombre = params[:nombre]
  apellidos = params[:apellidos]
  telefono = params[:telefono]
  localidad = params[:localidad]
  cp = params[:cp]
  direccion = params[:direccion]

registro = "DNI: #{dni}\nEmail: #{email}\nContraseña: #{password}\nConfirmar Contraseña: #{confirmPassword}\nNombre: #{nombre}\nApellidos: #{apellidos}\nTeléfono: #{telefono}\nLocalidad: #{localidad}\nCódigo Postal: #{cp}\nDirección: #{direccion}"
   end

   get '/verificar_dni' do
    content_type :json
    dni = params[:dni]
    existe = User.exists?(dni: dni)
    { existe: existe }.to_json
  end
 
end