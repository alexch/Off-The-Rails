# Off The Rails: Web Apps With Rack, Sinatra, Grape, and Siesta

This is a talk and related code written by Alex Chaffee about Rack apps and Ruby webapp frameworks that are *not* on Rails. It lives at <https://github.com/alexch/off-the-rails>

`off-the-rails.md` is the markdown document of the "slides" (more like notes) for the presentation.

`app.rb` is a little Rack app that renders the slides into HTML and wraps them in a page with some CSS. Run it with `ruby app.rb` (or `ruby -rrubygems app.rb` if you're on Ruby 1.8)

`rack/` and `sinatra/` contain sample apps and middleware that are referenced by the talk.

`rack/redirect_host.rb` is a middleware component pulled from a real app that redirects from one host to another, e.g. from `foo.heroku.com` to `www.foo.com`.
