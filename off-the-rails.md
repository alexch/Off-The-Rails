# Off The Rails: Web Apps With Rack, Sinatra, Grape, and Siesta

Ruby on Rails is the most popular web application framework for Ruby.
But it's not the only one! If you think Rails is too big, or too
opinionated, or too anything, you might be happy to learn about the
new generation of so-called microframeworks built on Rack. And since
Rails 3 is itself a Rack app, you don't have to give up Rails to get
the benefit of Sinatra routes or Grape APIs.

# Who am I?

### Alex Chaffee

* Cofounder of Cohuman
* Former principal of Pivotal Labs
* Co-creator of Pivotal Tracker
* Maintainer of several Open Source Projects
  * Wrong
  * Erector
  * rerun
* BTW I'm teaching a JS class starting January 27th
  * <http://classes.blazingcloud.net> -- sign up early for discount!

# What is Rails?

* Based on Conventions
  * Model-View-Controller Architecture
  * File layout

* Web Server
  * Routes
  * Opinionated REST pattern
  * Controllers

* Views
  * templates (ERB, HAML etc.)
  * "assigns" variables
  * partials
  * layouts

* Helpers
  * Date Helpers
  * String Helpers
  * Testing support
  * ActiveSupport

* ActiveRecord
  * Models
  * Migrations

* Scripts
  * Scaffolding
  * Rake tasks
  * script/*
    * script/console

* Load Path Management
  * mostly invisible, but very important
  * app subdir autoloading
  * views, models, controllers automatically located for you
    * "Both awesome and terrible." - Sarah Allen
  * plugins and engines
 
If you're considering going to a non-Rails framework, then it's important to understand all that Rails gives you, for two reasons:

1. If you want or need a Rails feature, does the new framework implement it? And if not, how much work would it be to reimplement it?
2. If you don't need a Rails feature, how much simpler would your non-Rails code be without it?

Consider development, maintenance, and education effort in your decision.
 
## Why not use Rails?

* Don't like all the magic
* Don't need migrations or scaffolding or MVC or database or...
* Don't like the file layout
* Don't like unencapsulated miscegeny between controllers and views
* Too Complex (right tool for the job)
* Performance

You might be thinking, "Wait, did he just say, 'Don't need MVC?' But isn't MVC the best architecture ever, handed down by God during the dark ages of the late 1990s?" Well, maybe, but plenty of webapps have different architectures and they're doing fine. For instance, most PHP apps are essentially Views with no models or controllers. And on the other side, Controllers and Models can be replaced or augmented with other patterns like Commands or Presenters or Components.

# Rack

* A Web Server Gateway Interface
* Based on Python's WSGI
* Sits between web server and web app (or apps)
* Adapters exist for...
  * Servers: Mongrel, WEBrick, FCGI, Thin, etc.
  * Frameworks: Rails, Camping, Sinatra, Merb, etc.

## Rack Apps

A Rack application is an Ruby object that responds to `call`.
It takes exactly one argument, the *environment* 
and returns an Array of exactly three values:
The *status*,
the *headers*,
and the *body*. The body must respond to `each` (so, sadly, it can't be a String in Ruby 1.9).

    class HelloApp
      def self.call(env)
        [200, {'Content-Type' => 'text/plain'}, ["Hello"]]
      end
    end
    
An app is usually configured in a file called `config.ru` like this:

    require './hello'
    run HelloApp

An app can also be a proc or lambda, since it responds to call. So this works too:

    run lambda {|env| [200, {'Content-Type' => 'text/plain'}, ["Hello"]]}

`env` is a hash containing normal CGI environment variables as well as some extra Rack stuff. (Use the PrintEnv middleware, in this talk's github repo, to see it.)

## Rack Middleware
* Not "shelf" :-(
* "ware" is a suffix indicating a "count noun" (or "mass noun"), which in English cannot exist in singular form without a modifier like "piece of" [furniture] or "glass of" [water]. So it feels intensely awkward for native English speakers to say "a middleware".

A Rack middleware is a class that is initialized with an app, plus optional arguments. It saves the app (usually in an @app instance variable) and usually calls it somewhere in its own `call` method.

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
    
## rack-contrib

* <https://github.com/rack/rack-contrib>
* More middleware than you can shake a stick at
* Some highlights:
  * [todo]

## Rackup and config.ru

* `rackup` is a command-line tool that launches a Rack server
* it reads app configuration, in Rack::Builder DSL format, from `config.ru`.

`hello_app.ru`:

    require './hello_app'
    require './print_env'
    use PrintEnv
    use Rack::ShowExceptions
    run HelloApp

## rerun

* gem written by me
* watches the file system and reruns the given app if a file changes
* if passed a `.ru` file, it calls rackup on it

    `rerun hello_app.ru`
    
## Rack::Request

Very useful object that's built from an env

  * params
  * etc.
  
## Mixing Apps

* `Rack::Builder` implements the normal Rack `.ru` DSL on the passed-in block and returns an app
* `Rack::URLMap` dispatches to separate apps based on path
  * e.g. `Rack::URLMap.new("/app1" => AppOne.new, "/app2" => AppTwo.new)`
* `Rack::Cascade` tries an request on several apps, and returns the first response that is not 404 (or in a list of configurable status codes).

## Testing Rack Apps

### rack/mock

  * `require 'rack/mock'`
  * Rack::MockRequest
  * Rack::MockResponse  
  * no sessions or cookie management

### rack-test

    gem install rack-test
    require 'rack/test'
    include Rack::Test::Methods
    
  * Gives your tests an interface for web conversations
  * Methods include:
    request,
    get,
    post,
    put,
    delete,
    head,
    follow_redirect!,
    header,
    set_cookie,
    clear_cookies,
    authorize,
    basic_authorize,
    digest_authorize,
    last_response,
    last_request
  *  Maintains a cookie jar across requests
  *  Easily follow redirects when desired
  *  Set request headers to be used by all subsequent requests
  *  Small footprint. Approximately 200 LOC

### rack-client

Integration (over-the-wire) testing for HTTP apps, closely tracking the rack-test interface so you can easily switch between local and remote tests. E.g. use Rack::Cache and rack-test in development, then switch to Varnish and rack-client for staging tests.

## Sample Rack App: This Talk

    git clone git://github.com/alexch/Off-The-Rails.git
    cd Off-The-Rails
    ruby app.rb
    
It launches a rack server that renders out this markdown file with some extra CSS using Erector.

(If you're on Ruby 1.8 you may need to do `ruby -rrubygems app.rb` or you'll get a `app.rb:1:in `require': no such file to load -- rack (LoadError)`.)

# Sinatra

A web framework built on Rack.

## Hello World

    require 'sinatra'
    get '/hi' do
      "Hello World!"
    end

    ruby hello.rb
    
Yes, that's it. No model, no view, no controller: just a route and a handler block.

## Sinatra Routes

    get '/foo' do
      erb :foo_index
    end

    post '/foo' do
      id = create_foo(params)
      redirect "/foo/#{id}"
    end

    get '/foo/:id' do
      read_foo(params[:id])
      haml :foo
    end

    put '/foo/:id' do |foo_id| # alternative to using params
      update_foo(foo_id)
      redirect "/foo/#{foo_id}"
    end

    delete '/foo/:id' do
      delete_foo(params[:id])
      redirect "/foo"
    end

Note: there is no "controller" *per se* in Sinatra -- just an application and routes and handlers.

## Sinatra DSL Features

* Settings
  * `set :sessions, true`
* Init blocks
  * `configure do ... end` happen at app startup
  * `before do...end` happen before each request and can modify the request and response
  * `after do...end` happen after each request and can modify the request and response
* Error handling
  * `halt 404`
  * `not_found do...end` for 404s
  * `error do...end` for exceptions
  * `error 403 do...end` for status codes
* Passing
  * from one route handler to the next

## More Sinatra Features

* Sinatra apps are also middleware, so you can chain them
* Also you can mix a Rails app with a Sinatra app
  * e.g. make your landing page and marketing site a Sinatra app, but pass logged-in users to your Rails app
  * use Rack::Cascade or Rack::URLMap for this
* `class MyApp < Sinatra::Base` for more modularity
  * though you still can't break your app up into multiple classes
  * workaround: use 'load' and have sub-files reopen MyApp
* Sessions (via Rack::Session)

## SinWiki: a sample Sinatra MVC app

SinWiki is a Sinatra app I whipped up for this talk. It uses a model (domain object) that is really just an in-memory hash table, as a standin for a "real" persistent object. It has Sinatra routes for the standard REST/CRUD methods, each of which ends with an inline Erector view. (The views should probably be externalized into classes.)

## Vegas: Sinatra has a backup band

* Vegas is a sample app skeleton I wrote in 2009
* Adds features to Sinatra to bring it to parity with Rails
  * Load Path management
  * ActiveRecord integration
  * rake tasks for server management and deployment
* Cohuman is based on Vegas (though heavily modified by now)

# Grape

* Like Sinatra for API apps
  * authentication
  * opinionated path

# Siesta

* Experimental controllerless framework
* Any object can become a RESTful resource
  * If that object is a view, it gets GET
  * If it's persistent, it gets GET, POST, DELETE, /new, etc.
  * Siesta handles core functionality and hands off to Handlers and Commands and Views for specialized work

## Mounting Rack apps inside a Rails app

* in `routes.rb`: `mount MyApp.new, :at => '/myapp`
* Probably more to it :-)

# References

* This talk lives at <https://github.com/alexch/off-the-rails>
* [Yehuda's #10 Favorite Thing About Ruby](http://yehudakatz.com/2009/08/24/my-10-favorite-things-about-the-ruby-language/)
* [Rack](http://rack.rubyforge.org/)
** [rack-test](https://github.com/brynary/rack-test)
** [rack-client](https://github.com/halorgium/rack-client)
* [Sinatra](http://sinatrarb.com)
* [Grape](https://github.com/intridea/grape)
* [Vegas](https://github.com/alexch/vegas)
* [Siesta](https://github.com/alexch/siesta)
* [Rerun](https://github.com/alexch/rerun)
* [Cans](https://github.com/bkerley/cans) a Rack app source browser
