module AppHelpers
    def partial(template, locals = {})
      erb(:"partial/#{template}", locals: locals)
    end
  
    def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
  
    def current_card
      @current_card ||= current_user.bank_account.card if current_user
    end
  
    def active_page
      @active_page ||= request.path_info.split('/')[1].to_s
    end

    def authenticate_user!
  protected_paths = [
    '/index', '/pay', '/transfer', '/transactions',
    '/personal_data', '/personal_data/', '/cards', '/cards/',
    '/saving_goals', '/saving_goal', '/toggle_theme'
  ]
  path = request.path_info.chomp('/') # quita barra final
  if protected_paths.any? { |p| path == p.chomp('/') || path.start_with?("#{p.chomp('/')}/") }
    redirect '/login' unless session[:user_id]
  end
end
  
    def dark_mode?
      session[:dark_mode] || false
    end
  
    def admin?
      current_user && !current_user.account.admin.nil?
    end
    
    def transaction_display_data(transaction)
  case transaction.transaction_type
  when "deposit"
    sign = '+'
    owner = "Depósito"
    amount_display = "+$#{transaction.amount}"
    amount_class = "amount-positive"
    case transaction.state
    when "success"
      type = "finalizado"
    when "rejected"
      type = "rechazado"
    when "pending"
      type = "pendiente"
    else
      type = "Desconocido"
    end
  when "withdrawal"
    sign = '-'
    owner = "Retiro"
    amount_display = "-$#{transaction.amount}"
    amount_class = "amount-negative"
    case transaction.state
    when "success"
      type = "finalizado"
    when "rejected"
      type = "rechazado"
    when "pending"
      type = "pendiente"
    else
      type = "Desconocido"
    end
  else
    other_user = transaction.target_account&.user
    sign = other_user&.name&.slice(0)&.upcase || "?"
    owner = other_user ? "#{other_user.name} #{other_user.last_name}" : "Usuario desconocido"
    if transaction.target_account == current_user.bank_account
       amount_class = "amount-positive"
      amount_display = "+$#{transaction.amount}"
    end
    if transaction.source_account == current_user.bank_account
      amount_class = "amount-negative"
      amount_display = "-$#{transaction.amount}"
    end
    type = "Transferencia"
  end
  {
    icon: sign,
    name: owner,
    type: type,
    amount_class: amount_class,
    amount: amount_display
  }
end
end
