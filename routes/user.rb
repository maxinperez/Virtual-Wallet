require File.expand_path('../../config/enviroment', __FILE__)

class UserRoutes < Sinatra::Base
  register AppConfig
  before { authenticate_user! }
  
  before do
    response.headers['Cache-Control'] = 'no-store'
  end

  get '/personal_data/' do
    erb :personal_data, layout: :'partial/layout'
  end

  get '/cards/' do
    erb :cards, layout: :'partial/layout'
  end

  post '/cards/:id/delete' do
    if params[:id].nil? || params[:id].empty?
      session[:error] = "ID de tarjeta no proporcionado."
      redirect '/cards/'
    end

    card = Card.find(params[:id])
    if card.bank_account.user != current_user
      session[:error] = "No tienes permiso para eliminar esta tarjeta."
    else
      card.destroy
      session[:success] = "Tarjeta eliminada correctamente."
    end
  redirect '/cards/'
end

  # Ruta para congelar tarjeta
  post '/cards/:id/freeze' do
    begin
      card = Card.find(params[:id])

      if card.bank_account.user != current_user
        session[:error] = "No tienes permiso para modificar esta tarjeta."
      else
        card.freeze!
        session[:success] = "Tarjeta congelada correctamente."
      end
    rescue ActiveRecord::RecordNotFound
      session[:error] = "Tarjeta no encontrada."
    end

    redirect '/cards/'
  end

  # Ruta para descongelar tarjeta
  post '/cards/:id/unfreeze' do
    begin
      card = Card.find(params[:id])

      if card.bank_account.user != current_user
        session[:error] = "No tienes permiso para modificar esta tarjeta."
      else
        card.unfreeze!
        session[:success] = "Tarjeta activada correctamente."
      end
    rescue ActiveRecord::RecordNotFound
      session[:error] = "Tarjeta no encontrada."
    end

    redirect '/cards/'
  end

  post '/cards/:id/set_limit' do
    begin
      card = Card.find(params[:id])

      # Verificamos que el usuario sea dueño de la tarjeta
      if card.bank_account.user != current_user
        session[:error] = "No tienes permiso para modificar esta tarjeta."
        redirect '/cards/'
      end

      # Validar que el límite sea un número positivo
      new_limit = params[:limit].to_f
      if new_limit <= 0
        session[:error] = "El límite debe ser un número positivo."
        redirect '/cards/'
      end

      card.update(limit: new_limit)
      session[:success] = "Límite actualizado correctamente."

    rescue ActiveRecord::RecordNotFound
      session[:error] = "Tarjeta no encontrada."
    end

    redirect '/cards/'
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
          address: params[:address],
          email: params[:email]
        )
        
        if bank_account.alias != params[:alias]
          bank_account.update(alias: params[:alias])
        end
        redirect '/personal_data/'
  end

  post '/personal_data/delete_account' do
    user = current_user

    # Eliminamos dependencias manualmente
    if user.bank_account
      user.bank_account.card&.destroy
      user.bank_account.saving_goals.destroy_all
      user.bank_account.all_transactions.destroy_all

      # Luego eliminamos la cuenta bancaria
      user.bank_account.destroy
    end

    # Finalmente eliminar al usuario
    user.destroy

    session.clear
    redirect '/login?goodbye=true'
  end


  
  get '/index' do
    session[:admin_active] = false
    user = current_user
    if user&.bank_account
      @transactions = user.bank_account.most_recent_transactions
      @frequent_recipients = user.bank_account.frequent_recipients
      @first_saving_goal = user.bank_account.saving_goals.order(:created_at).first
    else
      @transactions = []
      @frequent_recipients = []
      @first_saving_goal = nil
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

    amount = params[:amount].to_s.tr(',', '.').to_f
    account = current_user.bank_account

    if amount <= 0
      session[:error] = "El monto debe ser mayor que cero"
      redirect '/deposit'
    else
      transaction = Transaction.new(
        target_account: account,
        amount: amount,
        transaction_type: :deposit,
        state: 1
      )
      if transaction.save
        session[:success] = "Depósito solicitado. Esperando aprobación de un administrador."
      else
        session[:error] = transaction.errors.full_messages.join(', ')
      end
      redirect '/deposit'
    end
  end

  get '/withdraw' do
    redirect '/login' unless current_user

    @error = session.delete(:error)
    @success = session.delete(:success)

    erb :withdraw, layout: :'partial/layout'
  end

  post '/withdraw' do
    redirect '/login' unless current_user

    amount = params[:amount].to_s.tr(',', '.').to_f
    account = current_user.bank_account

    if amount <= 0
      session[:error] = "El monto debe ser mayor que cero"
      redirect '/withdraw'
    end

    if amount > account.balance
      session[:error] = "Saldo insuficiente para realizar el retiro"
      redirect '/withdraw'
    end

    transaction = Transaction.new(
      target_account: account,
      amount: amount,
      transaction_type: :withdrawal,
      state: :pending
    )

    if transaction.save
      session[:success] = "Retiro solicitado. Esperando aprobación de un administrador."
    else
      session[:error] = transaction.errors.full_messages.join(', ')
    end

    redirect '/withdraw'
  end

  get '/saving_goals' do
  @saving_goals = SavingGoal.where(bank_account: current_user.bank_account)
  @error = session.delete(:error)
  @success = session.delete(:success)
  erb :saving_goals, layout: :'partial/layout'
end

get '/saving_goals/new' do
  erb :new_goal, layout: :'partial/layout'
end

post '/saving_goals' do
  goal = SavingGoal.new(
    name: params[:name],
    target_amount: params[:target_amount].to_f,
    bank_account: current_user.bank_account,
    saved_amount: 0.0
  )

  if goal.save
    session[:success] = "Meta creada con éxito"
    redirect '/saving_goals'
  else
    session[:error] = goal.errors.full_messages.join(", ")
    redirect '/saving_goals/new'
  end
end

get '/saving_goals/:id' do
  begin
    @goal = SavingGoal.find(params[:id])
    
    # Verificar que la meta pertenece al usuario actual
    unless @goal.bank_account == current_user.bank_account
      session[:error] = "No tienes acceso a esta meta"
      redirect '/saving_goals'
    end
    
    @error = session.delete(:error)
    @success = session.delete(:success)
    erb :goal_detail, layout: :'partial/layout'
    
  rescue ActiveRecord::RecordNotFound
    session[:error] = "Meta no encontrada"
    redirect '/saving_goals'
  end
end

post '/saving_goals/:id/deposit' do
  begin
    goal = SavingGoal.find(params[:id])
    
    # Verificar que la meta pertenece al usuario actual
    unless goal.bank_account == current_user.bank_account
      session[:error] = "No tienes acceso a esta meta"
      redirect '/saving_goals'
      return
    end
    
    amount = params[:amount].to_f
    
    # Validar monto
    if amount <= 0
      raise "El monto debe ser mayor a 0"
    end
    
    goal.deposit(amount)
    session[:success] = "Depósito realizado con éxito"
    
  rescue ActiveRecord::RecordNotFound
    session[:error] = "Meta no encontrada"
  rescue => e
    session[:error] = e.message
  end

  redirect "/saving_goals/#{params[:id]}"
end

post '/saving_goals/:id/withdraw' do
  begin
    goal = SavingGoal.find(params[:id])
    
    # Verificar que la meta pertenece al usuario actual
    unless goal.bank_account == current_user.bank_account
      session[:error] = "No tienes acceso a esta meta"
      redirect '/saving_goals'
      return
    end
    
    amount = params[:amount].to_f
    
    # Validar monto
    if amount <= 0
      raise "El monto debe ser mayor a 0"
    end
    
    if amount > goal.saved_amount
      raise "Fondos insuficientes. Disponible: $#{'%.2f' % goal.saved_amount}"
    end
    
    goal.withdraw(amount)
    session[:success] = "Retiro realizado con éxito"
    
  rescue ActiveRecord::RecordNotFound
    session[:error] = "Meta no encontrada"
  rescue => e
    session[:error] = e.message
  end

  redirect "/saving_goals/#{params[:id]}"
end

# Ruta para eliminar meta 
delete '/saving_goals/:id' do
  begin
    goal = SavingGoal.find(params[:id])
    
    # Verificar que la meta pertenece al usuario actual
    unless goal.bank_account == current_user.bank_account
      session[:error] = "No tienes acceso a esta meta"
      redirect '/saving_goals'
      return
    end
    
    # Solo permitir eliminar si no tiene fondos
    if goal.saved_amount > 0
      session[:error] = "No puedes eliminar una meta que tiene fondos ahorrados"
    else
      goal.destroy
      session[:success] = "Meta eliminada con éxito"
    end
    
  rescue ActiveRecord::RecordNotFound
    session[:error] = "Meta no encontrada"
  rescue => e
    session[:error] = e.message
  end

  redirect '/saving_goals'
end

delete '/saving_goals/:id' do
  begin
    goal = SavingGoal.find(params[:id])
    
    # Verificar que la meta pertenece al usuario actual
    unless goal.bank_account == current_user.bank_account
      session[:error] = "No tienes acceso a esta meta"
      redirect '/saving_goals'
      return
    end
    
    # Solo permitir eliminar si no tiene fondos
    if goal.saved_amount > 0
      session[:error] = "No puedes eliminar una meta que tiene fondos ahorrados. Retira todos los fondos primero."
    else
      goal.destroy
      session[:success] = "Meta eliminada con éxito"
    end
    
  rescue ActiveRecord::RecordNotFound
    session[:error] = "Meta no encontrada"
  rescue => e
    session[:error] = e.message
  end

  redirect '/saving_goals'
end

end