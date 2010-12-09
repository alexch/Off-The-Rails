require 'rack'
require 'rdiscount'
require 'erector'

class Erector::Widget
  def markdown(s)
    rawtext Markdown.new(s).to_html
  end

  def stylesheet(href)
    link :rel=>"stylesheet", :type=>"text/css", :href=> href
  end
end

class Page < Erector::Widgets::Page
  external :style, <<-CSS
  body { font: normal normal normal 14pt/normal helvetica, arial, freesans, clean, sans-serif; }
  h1 { margin-top: 10em; border-top: 4px solid #AAA !important; padding-top: .25em; }
  h2 { margin-top: 5em; border-top: 4px solid #E0E0E0 !important; padding-top: .25em; }
  h1:first-child { margin-top: 1em; }
  pre { margin-left: 2em; margin-right: 2em; border: 1px solid black; padding: .5em; background: #EEEEFF;}
  CSS
  
  def body_content
    markdown File.read("off-the-rails.md")
  end
end

class OffTheRails
  def self.call(env)
    html = Page.new.to_html    
    [200, {'Content-Type' => 'text/html'}, [html]]
  end
end


if $0 == __FILE__
  app = Rack::Builder.new do
    use Rack::ShowExceptions
    run OffTheRails
  end
  
  # Rack::Server.start(:app => app)   # this is supposed to work, but doesn't  
  Rack::Handler::Thin.run app, :Port => 8888
end
