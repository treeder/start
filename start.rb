require 'rest'
require 'trollop'
require 'pp'

opts = Trollop::options do 
  opt :ghuser, "Github username", :type => :string
  opt :ghpass, "Github password", :type => :string
  opt :email, "Email", :type => :string
  opt :name, "Full name", :type => :string
end
Trollop::die :ghuser, "required" unless opts[:ghuser]
Trollop::die :ghpass, "required" unless opts[:ghpass]
Trollop::die :email, "required" unless opts[:email]
Trollop::die :name, "required" unless opts[:name]
# p opts

# Setup git config
puts "Configuring git"
puts `git config --global user.email "#{opts[:email]}"`
puts `git config --global user.name "#{opts[:name]}"`
# Next line only required until git 2.0 comes out
puts `git config --global push.default simple`

# Setup .netrc for GitHub
rest = Rest::Client.new
resp = rest.post("https://api.github.com/authorizations", 
  headers: {"Authorization" => "Basic " + ["#{opts[:ghuser]}:#{opts[:ghpass]}"].pack('m').delete("\r\n")},
  body: '{"scopes":["repo"],"note":".netrc token"}'
)
body = JSON.parse(resp.body)
ghtoken = body["token"]
puts "Writing token to .netrc file"
File.open("../.netrc", 'w') {|f| f.write("machine github.com login #{ghtoken}\n") }
