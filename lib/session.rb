require 'json'

class Session
  def initialize(req)
    cookie_hash = req.cookies['_frame_app']

    if cookie_hash
      @session_data = JSON.parse(cookie_hash)
    else
      @session_data = {}
    end
  end

  def [](key)
    @session_data[key]
  end

  def []=(key, val)
    @session_data[key] = val
  end

  def store_session(res)
    res.set_cookie('_frame_app', {path: '/', value: @session_data.to_json})
  end
end
