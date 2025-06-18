require File.expand_path('../../config/enviroment', __FILE__)

class AdminRoutes < Sinatra::Base
  register AppConfig

  #  renderiza el dashboard principal de administración
  get '/admins' do
    erb :"admin/dashboard_admin", layout: :'partial/admins'
  end

  #    renderiza página de gestión administrativa
  get '/management' do
    erb :"admin/management", layout: :'partial/admins'
  end

  #   muestra usuarios sin rol admin, mensajes del usuario seleccionado y renderiza la vista soporte con layout admin.
  get '/support' do
    halt(403, "Acceso denegado") unless admin?

    @users = Account.where(admin: nil)
    @selected_user = Account.find_by(id: params[:user_id]) if params[:user_id]
    @messages = @selected_user ? Message.where(user_id: @selected_user.id).order(:created_at) : []

    erb :"admin/support", layout: :'partial/admins'
  end

  #   retorna los mensajes del usuario seleccionado sin layout, vista para el admin
  get '/support/messages' do
    halt(403, "Acceso denegado") unless admin? || current_user
    
    @selected_user = Account.find_by(id: params[:user_id])
    @messages = @selected_user ? Message.where(user_id: @selected_user.id).order(:created_at) : []

    erb :"admin/_messages", layout: false
  end

  #   devuelve mensajes del usuario actual sin layout, vista para el usuario
  get '/chat/messages' do
    @user = current_user
    @messages = Message.where(user_id: @user.id).order(:created_at)

    erb :'admin/_messages', layout: false
  end

  #  respuestas de admin a usuarios
  post '/support' do
    user_id = params[:user_id]
    content = params[:content]
    if user_id && content && !content.strip.empty?
      Message.create(user_id: user_id, content: content, from_admin: true)
    end
    redirect "/support?user_id=#{user_id}"
  end

  # usuarios normales ven su chat, admin es redirigido a soporte
  get '/chat' do
    redirect '/support' if admin?
    @messages = Message.where(user_id: current_user.id).order(:created_at)
    erb :chat, layout: :'partial/layout'
  end

  #  usuario envía un mensaje desde el chat
  post '/chat' do
    Message.create(user_id: current_user.id, content: params[:content], from_admin: false)
    redirect '/chat'
  end

  #  el admin cierra un caso de soporte, borrando todos los mensajes del usuario
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

end
