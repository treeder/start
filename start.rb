require 'rest'
require 'trollop'
require 'pp'

opts = Trollop::options do 
  opt :ghuser, "Github username", :type => :string
  opt :ghpass, "Github password", :type => :string
end
Trollop::die :ghuser, "required" unless opts[:ghuser]
Trollop::die :ghpass, "required" unless opts[:ghpass]
# p opts

rest = Rest::Client.new
resp = rest.post("https://api.github.com/authorizations", 
  headers: {"Authorization" => "Basic " + ["#{opts[:ghuser]}:#{opts[:ghpass]}"].pack('m').delete("\r\n")},
  body: '{"scopes":["repo"],"note":".netrc token"}'
)
body = JSON.parse(resp.body)
ghtoken = body["token"]
puts "Writing token to .netrc file"
File.open(".netrc", 'w') {|f| f.write("machine github.com login #{ghtoken}\n") }
