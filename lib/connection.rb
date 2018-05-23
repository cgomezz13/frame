require 'rack'
require './router'


class Connection

  def self.start
    app = Proc.new do |env|
      req = Rack::Request.new(env)
      res = Rack::Response.new
      Router.run(req, res)
      res.finish
    end

    Rack::Server.start(
      app: app,
      Port: 3000
    )
  end

end
