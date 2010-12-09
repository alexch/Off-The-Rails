class HelloApp
  def self.call(env)
    [200, {'Content-Type' => 'text/plain'}, ["Hello, Cleveland!!!"]]
  end
end

# Alternative to "rackup hello_app.ru" so you can just run this file directly
if $0 == __FILE__
  require 'rack'
  require './print_env'
  app = Rack::Builder.new do
    use PrintEnv
    use Rack::ShowExceptions
    run HelloApp
  end
  
  # Rack::Server.start(:app => app)   # this is supposed to work, but doesn't  
  Rack::Handler::Thin.run app
end
