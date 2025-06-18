require File.expand_path('../../config/enviroment', __FILE__)

class GeneralRoutes < Sinatra::Base
  register AppConfig
  get '/toggle_theme' do
    session[:dark_mode] = !session[:dark_mode]
    redirect back
    end
  
    get '/' do
     erb :main, layout: :'partial/header'
    end 
  
    before do
      protected_paths = ['/index', '/pay', '/transfer', '/transactions']
      if protected_paths.include?(request.path_info) && !session[:dni] # request.path_info solo devuelve la ruta sin la query
        redirect '/login'
      end
    end

end