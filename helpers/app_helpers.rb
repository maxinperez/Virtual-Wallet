module AppHelpers
    def partial(template, locals = {})
      erb(:"partial/#{template}", locals: locals)
    end
  
    def current_user
      @current_user ||= User.find_by(dni: session[:dni]) || User.find_by(email: session[:dni]) if session[:dni]
    end
  
    def current_card
      @current_card ||= current_user.bank_account.card if current_user
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
  