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
    protected_paths = ['/index', '/pay', '/transfer', '/transactions']
    path = request.path_info.chomp('/')
    if protected_paths.any? { |p| path == p || path.start_with?("#{p}/") }
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
      amount_display = "#{transaction.amount}"
      case transaction.state
      when "success"
        amount_class = "amount-positive"
        type = "finalizado"
      when "rejected"
        amount_class = "amount-rejected"
        type = "rechazado"
      when "pending"
        amount_class = "amount-pending"
        type = "pendiente"
      else
        amount_class = "amount-positive"
        type = "Desconocido"
      end
    when "withdrawal"
      sign = '-'
      owner = "Retiro"
      amount_display = "#{transaction.amount}"
      case transaction.state
      when "success"
        amount_class = "amount-negative"
        type = "finalizado"
      when "rejected"
        amount_class = "amount-negative"
        type = "rechazado"
      when "pending"
        amount_class = "amount-pending"
        type = "pendiente"
      else
        amount_class = "amount-negative"
        type = "Desconocido"
      end
    else
      other_user = transaction.source_account&.user
      sign = other_user&.name&.slice(0)&.upcase || "?"
      owner = other_user ? "#{other_user.name} #{other_user.last_name}" : "Usuario desconocido"
      amount_display = "#{transaction.amount}"
      type = "Transferencia"
      case transaction.state
      when "success"
        amount_class = "amount-negative"
        type = "finalizado"
      when "rejected"
        amount_class = "amount-rejected"
        type = "rechazado"
      when "pending"
        amount_class = "amount-pending"
        type = "pendiente"
      else
        amount_class = "amount-negative"
        type = "Desconocido"
      end
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
