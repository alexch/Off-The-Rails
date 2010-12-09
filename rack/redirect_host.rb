# A Rack middleware component that redirects from old host to new host.
#
# To use, put 
#     use RedirectHost, :from => "www.foo.com", :to => "foo.com" 
# in your Rack config or Sinatra app.
#
# :from can be multiple hosts, comma-delimited. e.g.
#     :from => "www.foo.com,foo.heroku.com"
#
class RedirectHost 
  def initialize(app, options = {})
    @app = app
    @options = options 
  end
   
  def from_hosts
    options[:from].split(",")
  end
  
  def to_host
    options[:to]
  end
 
  def call(env)
    if from_hosts.include?(env['SERVER_NAME'])
      destination  = "#{env['rack.url_scheme']}://#{to_host}"
      destination << ifblank(env['PATH_INFO'], '/')
      destination << "?#{env['QUERY_STRING']}" unless env['QUERY_STRING'].empty?

      [301, {'Location' => destination}, ["redirecting to <a href='#{destination}'>#{destination}</a>"]]
    else
      @app.call(env)
    end
  end
  
  def ifblank(s, default = "")
    if s.blank?
      default
    else
      s
    end
  end

end
