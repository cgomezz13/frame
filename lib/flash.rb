require 'json'

class Flash

  attr_reader :now

  def initialize(req)
    cookie_hash = req.cookies['_rails_lite_app_flash']

    @now = cookie_hash ? JSON.parse(cookie_hash) : {}
    @flash = {}
  end

  def [](key)
    @now[key.to_s] || @flash[key.to_s]
  end

  def []=(key,value)
    @flash[key.to_s] = value
  end

  def store_flash(res)
    res.set_cookie('_rails_lite_app_flash', {path: '/', value: @flash.to_json})
  end

end
