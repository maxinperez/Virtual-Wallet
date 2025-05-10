require 'sinatra/base'

# Define una clase 'App' que hereda de 'Sinatra::Application',
# convirtiéndola en una aplicación web Sinatra.
class App < Sinatra::Application
  # Define una ruta para solicitudes GET a la URL raíz ('/').
  get '/' do
    'Welcome'
  end
end