require 'json'
require 'open-uri'
require 'ipaddr'
require 'resolv'
require 'sinatra'

set :port, 8080
set :static, true
set :public_folder, 'static'
set :views, 'views'

URL = 'https://ip-ranges.amazonaws.com/ip-ranges.json'

get '/' do
  erb :index
end

get '/is-it-aws' do
  output = []
  errors = []
  name_to_check = params[:domain]

  begin
    ip_ranges = JSON.load(open(URL))
  rescue
    errors <<
      'Problems in retrieving information about IP ranges. Try later, please!'
  end
  begin
    ip_to_check   = Resolv.getaddress(name_to_check)
  rescue
    errors << 'Problems in retrieving the IP address of the domain.'
  end

  ip_ranges['prefixes'].each do |prefix|
    network_address = IPAddr.new(prefix['ip_prefix'])
    if network_address === ip_to_check
      output << prefix
    end
  end
  erb :show, :locals => {'errors' => errors, 'prefixes' => output}
end
