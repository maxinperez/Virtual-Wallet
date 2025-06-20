require File.expand_path('../../config/enviroment', __FILE__)

class GeneralRoutes < Sinatra::Base
  register AppConfig
  before { authenticate_user! }

  get '/toggle_theme' do
    session[:dark_mode] = !session[:dark_mode]
    redirect back
    end

    get '/' do
     erb :main, layout: :'partial/header'
    end 

end