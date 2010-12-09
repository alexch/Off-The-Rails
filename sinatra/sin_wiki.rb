require 'sinatra'
require 'erector'

include Erector::Mixin

# a simple in-memory wiki
class Wiki
  # singleton pattern
  def self.instance
    @instance ||= new
  end
  
  def initialize
    @pages = {}
    @next_id = 1
  end

  def add(name, body)
    id = @next_id
    @next_id += 1
    @pages[id] = Page.new(id, name, body)
    id
  end

  def get(id)
    @pages[id.to_i]
  end
  
  def pages
    @pages.values
  end
end

class Page < Struct.new(:id, :name, :body)
end

class SinWiki < Sinatra::Base
  set :run, true

  def wiki
    Wiki.instance
  end

  get '/' do
    erector {
      head { title "Welcome to SinWiki" }
      body {
        h1 "SinWiki"
        ul do
          li { a "new page", :href => "/page/new" }
          wiki.pages.each do |page|
            li { a page.name, :href => "/page/#{page.id}"}
          end
        end
      }
    }
  end

  get "/page/new" do
    erector {
      head { title "SinWiki: New Page" }
      body {
        h1 "SinWiki: New Page"

        form :method => "post", :action => "/page" do
          table do
            tr do
              td "Name"
              td { input :name => "name" }
            end
            tr do
              td "Body"
              td { textarea :name => "body" }
            end
            tr do
              td ""
              td { input :type => "submit" }
            end
          end
        end
      }
    }
  end

  post "/page" do
    id = wiki.add(params[:name], params[:body])
    redirect "/page/#{id}"
  end

  get "/page/:id" do |id|
    page = wiki.get(id)
    if page.nil?
      halt 404, "#{request.path} not found"
    end

    erector {
      head { title "SinWiki: #{page.name}"  }
      body {
        h1 "SinWiki"
        h2 page.name
        p page.body
        a "index", :href => "/"
      }
    }
  end

end

if $0 == __FILE__
  SinWiki.run! :host => 'localhost', :port => 9090
end
