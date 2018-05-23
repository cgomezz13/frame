require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params


  def initialize(req, res, route_params={})
    @req = req
    @res = res
    @params = req.params.merge(route_params)
    @already_built_response = false
  end


  def already_built_response?
    @already_built_response
  end


  def redirect_to(url)
    raise 'cannot render twice' if already_built_response?

    res.location = url
    res.status = 302
    @already_built_response = true
    session.store_session(res)
  end


  def render_content(content, content_type)
    raise 'cannot render twice' if already_built_response?

    res['Content-Type'] = content_type
    res.body = [content]
    @already_built_response = true
    session.store_session(res)
  end


  def render(template_name)
    dir = File.dirname(__FILE__)
    template = File.join(dir, '..', 'views', self.class.name.underscore, "#{template_name}.html.erb")

    content = File.read(template)
    render_content(ERB.new(content).result(binding), 'text/html')
  end


  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end

    send(name)
    render(name) unless already_built_response?

  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def check_authenticity_token
    cookie = @req.cookies['authenticity_token']
    unless cookie
      raise 'Invalid authenticity token'
    end
  end

  def form_authenticity_token
    @token ||= generate_authenticity_token
    res.set_cookie('authenticity_token', {value: @token, path: '/'})
    @token
  end

end
