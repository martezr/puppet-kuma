require 'fileutils'
require 'json'
require 'net/http'

# Implementation for the kuma dataplane token type using the Resource API.
Puppet::Type.type(:kuma_token).provide(:default) do
  def destroy
    FileUtils.rm_rf resource[:path]
  end

  def create
    dptoken = {}
    dptoken['Name'] = resource[:name]
    dptoken['Mesh'] = resource[:mesh]
#    dptoken['Tags'] = {}
#    dptoken['Tags']['kuma.io/service'] = ["backend", "backend-admin"]
    dptoken['Type'] = ""
    token = fetch_token(dptoken)
    File.write(resource[:path], token)
  end

  def exists?
      File.exist?(resource[:path])
  end
  
  def get
    tokenoutput = []
    output = {}
    # Parse token file on system
    if(File.exist?(resource[:path]))
      content = File.read(resource[:path])
      data = content.split(".")
      payload = JSON.parse(Base64.decode64(data[1]))
      tokenoutput << { name: resource[:path],
        ensure: 'present',
        mesh: payload['Mesh'] }
      return tokenoutput
    end
    return tokenoutput
  end

  def fetch_token(payload)
    uri = URI.parse("#{resource[:control_plane]}/tokens")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = JSON.dump(payload)
  
    req_options = {
      use_ssl: uri.scheme == "https",
      verify_mode: OpenSSL::SSL::VERIFY_NONE,
      cert: OpenSSL::X509::Certificate.new(resource[:client_cert]),
      key: OpenSSL::PKey::RSA.new(resource[:client_key])
    }
  
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    return response.body
  end
end
