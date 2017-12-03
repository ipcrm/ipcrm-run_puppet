#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'json'
require 'open3'

_param = STDIN.read
params = JSON.parse(_param)
certname = params['certname']

query = 'resources[title]{ (title ~ "^Profile*" or title ~ "^Role*" ) and certname = "%s" group by certname,title }' % [certname]
cmd_string = "/opt/puppetlabs/bin/puppet-query"
_,stdout,_,_ = Open3.popen3(cmd_string,query)

pclasses = []
JSON.parse(stdout.read).each do |c|
  pclasses.push(c["title"])
end

puts pclasses.join("\n")
