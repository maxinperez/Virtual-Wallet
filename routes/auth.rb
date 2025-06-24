require File.expand_path('../../config/enviroment', __FILE__)

class AuthRoutes < Sinatra::Base
  register AppConfig
  before { authenticate_user! }
  get '/verificar_dni' do
    content_type :json
    dni = params[:dni]
    existe = User.exists?(dni: dni)
    { existe: existe }.to_json
  end

  # renderiza el formulario de login
  get '/login' do  
    erb :login, layout: :'partial/header'
  end 

  # logout
  get '/logout' do 
    session.clear
    redirect '/login'
  end

  # renderiza el formulario de registro
  get '/register' do 
    erb :register, layout: :'partial/header'
  end 

  # solicitud para logearse
  post '/login' do 
    login_param = params[:dni]   
    password = params[:password]

    user = User.find_by(email: login_param)
    existing_user = user&.account || Account.find_by(username: login_param)

    if existing_user && existing_user.authenticate(password)
      session[:user_id] = existing_user.id
      redirect '/index'
    else 
      session[:error] = 'Datos inválidos'
      puts 'Invalid data'
      redirect '/login'
    end
  end

  # solicitud para registrarse
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

    halt 409, "El DNI ya está registrado"    if User.exists?(dni: dni)
    halt 409, "DNI inválido"                 if dni.length < 8
    halt 409, "El correo ya está registrado" if User.exists?(email: email)

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
      puts 'Usuario registrado correctamente'
      redirect '/login'
    else 
      puts 'Error al registrar el usuario'
      redirect '/register'
    end 
  end
  
  before ['/login', '/register'] do
    redirect '/index' if session[:user_id]
  end
end
