FROM ruby:3.3.8

# Define variables de entorno para Bundler:
# - BUNDLE_PATH: Directorio donde se instalan las gemas.
# - BUNDLE_APP_CONFIG: Ubicación del archivo de configuración de Bundler.
# - RAILS_ENV: Establece el entorno como desarrollo.
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle/config \
    RAILS_ENV=development

# Establece /app como el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia Gemfile y Gemfile.lock para instalar dependencias primero (aprovecha caché de Docker).
COPY Gemfile Gemfile.lock ./

# Ejecuta bundle install para instalar las gemas especificadas en el Gemfile.
RUN bundle install

# Copia todo el contenido del proyecto al directorio /app.
COPY . .

# Expone el puerto 8000 para acceso externo.
EXPOSE 8000

# Define el comando predeterminado para iniciar el contenedor:
# - bundle exec: Ejecuta comandos en el contexto de las gemas instaladas.
# - rackup: Inicia el servidor Rack.
# - -o 0.0.0.0: Escucha en todas las interfaces de red.
# - -p 8000: Usa el puerto 8000.
# Busca automáticamente config.ru para iniciar la aplicación.
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]