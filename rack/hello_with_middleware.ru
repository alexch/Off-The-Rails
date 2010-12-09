require './hello_app'
require './print_env'
use PrintEnv
use Rack::ShowExceptions
run HelloApp
