require File.expand_path('../../config/enviroment', __FILE__)

class UserRoutes < Sinatra::Base
  register AppConfig

  get '/personal_data/' do
    erb :personal_data, layout: :'partial/layout'
  end

  get '/cards/' do
    erb :cards, layout: :'partial/layout'
  end

  post '/generar_tarjeta' do
    unless Card.exists?(bank_account: current_user.bank_account)
      Card.create(
        bank_account: current_user.bank_account,
        holder_name: "#{current_user.name} #{current_user.last_name}"
      )
    end
    redirect back
  end

  put '/actualizar_cuenta' do
    user = User.find_by(session[:dni])
    account = user.account
    bank_account = user.bank_account

    user.update(
      name: params[:name], 
      last_name: params[:last_name], 
      locality: params[:locality], 
      cp: params[:cp], 
      address: params[:address]
    )
    
    if bank_account.alias != params[:alias]
      bank_account.update(alias: params[:alias])
    end

    if account.username != params[:email]
      account.update(username: params[:email])
    end

    redirect '/personal_data/'
  end

  get '/index' do
    user = User.find_by(dni: session[:dni])
    if user&.bank_account
      @transactions = user.bank_account.most_recent_transactions
      @frequent_recipients = user.bank_account.frequent_recipients
    else
      @transactions = []
      @frequent_recipients = []
    end
    @daily_expenses = Transaction.daily_expenses_last_month_for(current_user)
    erb :index, layout: :'partial/layout'
  end

  get '/transactions' do
    if current_user && current_user.bank_account
      @transactions = current_user.bank_account.all_transactions.order(created_at: :desc)
    else
      @transactions = []
    end
    erb :transactions, layout: :'partial/layout'
  end

  get '/deposit' do
    redirect '/login' unless current_user

    @bank_account = current_user.bank_account
    @success = session.delete(:success)
    erb :deposit, layout: :'partial/layout'
  end

  post '/deposit' do
    redirect '/login' unless current_user

    amount = params[:amount].to_f
    account = current_user.bank_account

    if amount <= 0
      session[:error] = "El monto debe ser mayor que cero"
      redirect '/deposit'
    else
      transaction = Transaction.new(
        target_account: account,
        amount: amount,
        transaction_type: :deposit,
        state: :pending
      )
      if transaction.save
        session[:success] = "Depósito solicitado. Esperando aprobación de un administrador."
      else
        session[:error] = transaction.errors.full_messages.join(', ')
      end
      redirect '/deposit'
    end
  end

end