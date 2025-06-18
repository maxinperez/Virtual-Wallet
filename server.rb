require 'bundler/setup'
require 'sinatra/base'
require 'sqlite3'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'sinatra/activerecord'
require 'logger'
require 'prawn'

class App < Sinatra::Application
  enable :sessions
  set :database, adapter: 'sqlite3', database: 'db/development.sqlite3'
  ActiveRecord::Base.logger = Logger.new(STDOUT) if development?
  use Rack::MethodOverride
  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

#buena practica
require_relative 'models/user'
require_relative 'models/bankaccount'
require_relative 'models/account'
require_relative 'models/transaction'
require_relative 'models/card'
require_relative 'models/message'


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
      @current_user ||= User.find_by(dni: session[:dni]) || User.find_by(email: session[:dni]) if session[:dni]
    end
    def current_card
      @current_card ||= current_user.bank_account.card
    end
    def active_page
        @active_page ||= request.path_info.split('/')[1].to_s
    end
    def dark_mode?
    session[:dark_mode] || false
    end
    def admin?
      current_user && !current_user.account.admin.nil?
    end

  end
  get '/toggle_theme' do
  session[:dark_mode] = !session[:dark_mode]
  redirect back
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

  get '/register' do 
    erb :register, layout: :'partial/header'
  end 

  get '/admins' do
    erb :"admin/dashboard_admin", layout: :'partial/admins'
  end

  get '/personal_data/' do
      erb :personal_data, layout: :'partial/layout'
    end

    get '/management' do
      erb :"admin/management", layout: :'partial/admins'
    end

    get '/support' do
      halt(403, "Acceso denegado") unless admin?
      @users = Account.where(admin: nil)
      @selected_user = Account.find_by(id: params[:user_id]) if params[:user_id]
      @messages = @selected_user ? Message.where(user_id: @selected_user.id).order(:created_at) : []
      erb :"admin/support", layout: :'partial/admins'
    end

    get '/support/messages' do
      halt(403, "Acceso denegado") unless admin? || current_user
    
      @selected_user = Account.find_by(id: params[:user_id])
      @messages = @selected_user ? Message.where(user_id: @selected_user.id).order(:created_at) : []
    
      erb :"admin/_messages", layout: false
    end

    get '/chat/messages' do
      @user = current_user
      @messages = Message.where(user_id: @user.id).order(:created_at)
    
      erb :'admin/_messages', layout: false
    end

    post '/support' do
        user_id = params[:user_id]
        content = params[:content]
        if user_id && content && !content.strip.empty?
          Message.create(user_id: user_id, content: content, from_admin: true)
        end
        redirect "/support?user_id=#{user_id}"
      end

    get '/chat' do
      redirect '/support' if admin?
      @messages = Message.where(user_id: current_user.id).order(:created_at)
      erb :chat, layout: :'partial/layout'
    end

    post '/chat' do
      Message.create(user_id: current_user.id, content: params[:content], from_admin: false)
      redirect '/chat'
    end

    delete '/support/close_case/:account_id' do
      halt(403, "Acceso denegado") unless admin?
      account = Account.find_by(id: params[:account_id])
      if account
        Message.where(user_id: account.id).delete_all
        redirect "/support?user_id=#{account.id}"
      else
        halt 404, "Cuenta no encontrada"
      end
    end

    get '/cards/' do 
      erb :cards, layout: :'partial/layout'
    end 

  get '/transfer' do 
   erb :transfer, layout: :'partial/layout'
  end


  post '/login' do 
    login_param = params[:dni]   
    password = params[:password]
    user = User.find_by(email: login_param)
    if user
    existing_user = user.account
    else
    existing_user = Account.find_by(username: login_param)
    end
    
    if existing_user && existing_user.authenticate(password)
      session[:dni] = params[:dni]
      redirect '/index'
    else 
      session[:error] = 'Datos invalidos'
      puts 'invalid data'
      redirect '/login'
    end
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
    halt 409, "el dni ya está registrado"
  end
  if dni.length < 8
    halt 409, "dni invalido"
  end

  if User.exists?(email: email)
    halt 409, "el correo ya esta registrado"
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

  post '/generar_tarjeta' do 
    unless Card.exists?(bank_account: current_user.bank_account)
      card = Card.create(
        bank_account: current_user.bank_account,
        holder_name: "#{current_user.name} #{current_user.last_name}"
      )
      redirect back
    end
  end

  get '/index' do 
    user = User.find_by(dni: session[:dni])
    if(user&.bank_account)
      @transactions = user.bank_account.most_recent_transactions
      @frequent_recipients = user.bank_account.frequent_recipients
    else 
      @transactions = []
      @frequent_recipients = []
    end
    
    @daily_expenses = Transaction.daily_expenses_last_month_for(current_user)
   erb :index, layout: :'partial/layout'
  end 



post '/transfer' do
  source = current_user.bank_account
  input = params[:destino] 
  target = BankAccount.find_by(cvu: input) || BankAccount.find_by(alias: input)
  
  @error=nil
  if target.nil?
    @error = "Cuenta destino no encontrada"
  elsif source == target
    @error = "No podés transferir a tu propia cuenta."
  end

  if @error
    return erb :transfer, layout: :'partial/layout'
  else  
    transfer = Transaction.new(
    source_account: source,
    target_account: target,
    amount: params[:amount],
    description: params[:description],
    motivo: params[:motivo],
    transaction_date: Time.now,
    transaction_type: 2,
    state: 0
    )
  end
  if transfer.save
     redirect "/transfer/success/#{transfer.id}"
  else
      @error = "No se pudo guardar la transferencia"
      erb :transfer, layout: :'partial/layout'
  end
 end

 get '/transfer/success/:id' do 
  
  @transfer = Transaction.includes( target_account: :user).find(params[:id])
  #Transaction.find_by(id: params[:id])
  halt 404, "Transferencia no encontrada" unless @transfer 


  random = SecureRandom.hex(2).upcase
  @transfer_code = "TRF-#{@transfer.id}-#{random}"
  @comprobante_code = "CBT-#{@transfer.id}-#{random}"
  erb :transfer_succes, layout: :'partial/layout'
end

get '/comprobante/:id' do
  @transfer = Transaction.includes(source_account: :user, target_account: :user).find(params[:id])

  random = SecureRandom.hex(2).upcase
  @transfer_code = "TRF-#{@transfer.id}-#{random}"
  @comprobante_code = "CBT-#{@transfer.id}-#{random}"
  
  sender = @transfer.source_account.user
  recipient = @transfer.target_account.user

  content_type 'application/pdf'
  pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: 50)

  # colores
  main_color = "0d9b72" # verde esmeralda
  gray_color = "444444"
  # fuente
  pdf.font "Helvetica"
  pdf.fill_color main_color
  pdf.text "Comprobante de Transferencia", size: 26, style: :bold, align: :center
  pdf.move_down 10

  pdf.stroke_color main_color
  pdf.stroke_horizontal_rule
  pdf.move_down 20

  #  remitente y destinatario 
  pdf.fill_color "000000"
  pdf.text "Remitente", size: 14, style: :bold, color: main_color
  pdf.text "#{sender.name} #{sender.last_name}", size: 12
  pdf.move_down 10

  pdf.text "Destinatario", size: 14, style: :bold, color: main_color
  pdf.text "#{recipient.name} #{recipient.last_name}", size: 12

  pdf.move_down 25
  pdf.stroke_horizontal_rule
  pdf.move_down 15

  # tabla con los detalles
  data = [
    ["Código de transferencia:", @transfer_code],
    ["Código de comprobante:", @comprobante_code],
    ["Monto:", "$#{'%.2f' % @transfer.amount}"],
    ["Motivo:", @transfer.motivo || 'Sin motivo especificado'],
    ["Fecha:", @transfer.transaction_date.getlocal.strftime('%d/%m/%Y %H:%M')]
  ]

  data.each do |label, value|
    pdf.formatted_text [
      { text: label, styles: [:bold], color: main_color },
      { text: " #{value}", color: gray_color }
    ]
    pdf.move_down 8
  end

  # footer
  pdf.move_down 40
  pdf.stroke_horizontal_rule
  pdf.move_down 5
  pdf.fill_color gray_color
  pdf.text "PayStack - Comprobante oficial uacho", size: 9, align: :center, style: :italic

  pdf.render
end


 put '/actualizar_cuenta' do
  user = User.find_by(session[:dni])
  account = user.account
  bank_account = user.bank_account
  user.update(name: params[:name], last_name: params[:last_name], locality: params[:locality], cp: params[:cp], address: params[:address] )
  if bank_account.alias != params[:alias] 
    puts bank_account.alias
    puts params[:alias] 
    bank_account.update(alias: params[:alias])
  end
  if account.username != params[:email] 
    account.update(username: params[:email]) 
  end
  redirect '/personal_data/'
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