class Manager
  require "uri"
  require "net/http"
  require 'ntlm/http'
  require 'json'

  def initialize(api_uri:, user:, password:, domain:)
    raise ArgumentError.new('password is required (CM_API_PASSWORD env var mising?)') if password.nil? || password == ''

    @server = api_uri # Rails.application.credentials.content_manager[:api_url] # 'http://admwebdoc1.borough.kenai.ak.us/CMServiceAPI'
    @user = user # Rails.application.credentials.content_manager[:user]
    @password = password # Rails.application.credentials.content_manager[:password]
    @domain = domain # Rails.application.credentials.content_manager[:domain]
  end

  def classification
    @classification ||= Classification.new(api_uri: @server, user: @user, password: @password, domain: @domain)
  end

  def location
    @location ||= Location.new(api_uri: @server, user: @user, password: @password, domain: @domain)
  end

  def record
    @record ||= Record.new(api_uri: @server, user: @user, password: @password, domain: @domain)
  end

  protected

  def get_response(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port);
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request.ntlm_auth(@user, @domain, @password)
    response = http.request(request)
    results = JSON.parse(response.read_body)

    message = results.fetch('ResponseStatus', {}).fetch('Message', '')
    if message && message != ''
      raise message
    end

    results
  end

  def get_all_items(url, q: nil, all: true)
    items = []
    loop do
      # pageSize is abitrary
      results = get_response(url + "?q=#{q || 'all'}&ExcludeCount=true&propertySets=Details&pageSize=250&start=#{items.count + 1}")
      items += results['Results']
      break if !results['HasMoreItems'] || !all
    end 
    
    items
  end

  def post_request(url, payload)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    #http.set_debug_output $stderr
    request = Net::HTTP::Post.new(uri)
    request.ntlm_auth(@user, @domain, @password)
    request["Accept"] = "application/json"

    if payload.keys.include?('Files')
      files = payload.delete 'Files'
      fields = payload.delete('Fields') || {}
      form_data = JSON.parse(payload.to_json).to_a + fields.map { |k,v| [k, v['Value']] }
      form_data.push [ 'Files', *files ]

      request.set_form form_data, 'multipart/form-data'
    else
      request["Content-Type"] = "application/json"
      request.body = payload.to_json
    end

    response = http.request(request)
    if response.is_a?(Net::HTTPNoContent)
      {}
    else
      JSON.parse(response.read_body)
    end
  end
end
