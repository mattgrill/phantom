require 'sinatra'
require 'net/https'
require 'yaml'
require 'json'

opts = YAML.load_file('config-example.yaml')

class Phantom
  def initialize(opts, request_path)
    @opts = opts
    @opts['request_path'] = request_path
  end

  def response
    http = Net::HTTP.new(@opts['acquia_server'], 443)
    http.use_ssl = true

    request = Net::HTTP::Get.new(@opts['api_version_prefix'] + @opts['request_path'])
    request.basic_auth @opts['credentials']['username'], @opts['credentials']['password']
    response = http.request(request)

    if response.code != '200'
      return JSON.generate({"http_code"=>"#{response.code}","http_msg"=>"#{response.msg}"})
    else
      return response.body
    end
  end

end

get '/api/*' do
  content_type :json
  Phantom.new( opts, params[:splat].join('/') ).response
end
