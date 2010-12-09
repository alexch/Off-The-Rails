require 'pp'

# A simple Rack Middleware that prints the environment
class PrintEnv
  def initialize(app)
    @app = app
  end

  def call(env)
    pp env
    @app.call(env)
  end
end
