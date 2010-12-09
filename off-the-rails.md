# Off The Rails: Web Apps With Rack, Sinatra, Grape, and Siesta

Ruby on Rails is the most popular web application framework for Ruby.
But it's not the only one! If you think Rails is too big, or too
opinionated, or too anything, you might be happy to learn about the
new generation of so-called microframeworks built on Rack. And since
Rails 3 is itself a Rack app, you don't have to give up Rails to get
the benefit of Sinatra routes or Grape APIs.

# Who am I

Alex Chaffee

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
  * plugins and engines
  * "Both awesome and terrible." - Sarah Allen
 
## Why not use Rails?

* Don't like all the magic
* Don't need migrations or scaffolding or MVC or database or...
* Don't like the file layout
* Don't like unencapsulated miscegeny between controllers and views
* Too Complex (right tool for the job)
* Performance

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
and the *body*. The body must respond to `each` (so can't be a String in Ruby 1.9).

    class HelloApp
      def self.call(env)
        [200, {'Content-Type' => 'text/plain'}, ["Hello"]]
      end
    end

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

e.g.

    rerun rackup hello_app.ru
    
## Rack::Request

Very useful object that's built from an env

  * params
  * etc.
  
# Mixing Apps

* `Rack::Builder`  
* `Rack::URLMap` dispatches to separate apps based on path
  * e.g. `Rack::URLMap.new("/app1" => AppOne.new, "/app2" => AppTwo.new)`
* `Rack::Cascade` tries an request on several apps, and returns the first response that is not 404 (or in a list of configurable status codes).

## Testing Rack Apps

### rack/mock

  * Rack::MockRequest
  * Rack::MockResponse  
  * no sessions or cookie management

### Rack::Test

`include Rack::Test::Methods`
   gives your tests a DSL for web conversations

    :request,
    :get,
    :post,
    :put,
    :delete,
    :head,
    :follow_redirect!,
    :header,
    :set_cookie,
    :clear_cookies,
    :authorize,
    :basic_authorize,
    :digest_authorize,
    :last_response,
    :last_request

# Sinatra

A web framework built on Rack.

## Hello World

    require 'sinatra'
    get '/hi' do
      "Hello World!"
    end

    ruby hello.rb
    
## Sinatra Routes

    post '/foo' do
      create_foo(params)
    end

    get '/foo/:id' do
      read_foo(params[:id])
    end

    put '/foo/:id' do
      update_foo(params[:id])
    end

    delete '/foo/:id' do
      delete_foo(params[:id])
    end

Note: there is no "controller" in Sinatra -- just an application and routes (aka handlers).

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

* Sinatra apps are middleware, so you can wrap a Rails app inside a Sinatra app
  * e.g. make your landing page and marketing site a Sinatra app, but pass logged-in users to your Rails app
* `class MyApp < Sinatra::Base` for more modularity
  * though you still can't break your app up into multiple classes
  * workaround: use 'load' and have sub-files reopen MyApp
* Sessions (via Rack::Session)

## SinWiki: a simple Sinatra MVC app

SinWiki is a Sinatra app I whipped up for this talk. It uses a model (domain object) that is really just an in-memory hash table, as a standin for a "real" persistent object. It has Sinatra routes for the standard REST/CRUD methods, each of which ends with an inline Erector view. (The views should probably be externalized into classes.)

## Vegas: Sinatra has a backup band

* Vegas is a sample app skeleton I wrote in 2009
* Adds features to Sinatra to bring it to parity with Rails
  * Load Path management
  * ActiveRecord integration
  * rake tasks for server management and deployment
* Cohuman is based on Vegas (though heavily modified)

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

* Sinatra apps are also middleware, so you can chain them

## Mounting Rack apps inside a Rails app

* in `routes.rb`: `mount MyApp.new, :at => '/myapp`
* Probably more to it :-)

# References

* [Yehuda's #10 Favorite Thing About Ruby](http://yehudakatz.com/2009/08/24/my-10-favorite-things-about-the-ruby-language/)
* <http://rack.rubyforge.org/>
* <http://sinatrarb.com>
* <https://github.com/intridea/grape>
* <https://github.com/alexch/vegas>
* <https://github.com/alexch/siesta>
* <https://github.com/alexch/rerun>
* <https://github.com/bkerley/cans/>
