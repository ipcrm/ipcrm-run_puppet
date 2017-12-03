#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'json'
require 'open3'

_param = STDIN.read
params = JSON.parse(_param)
role = params['role']
resource = params['resource']

query = 'reports[certname,logs]{ latest_report? = true and facts { name = "role" and value = "%s" } }' % [role]
cmd_string = "/opt/puppetlabs/bin/puppet-query #{query}"
_,stdout,_,_ = Open3.popen3(cmd_string)


out = stdout.readlines
out.pop
out.shift


JSON.parse(out)["logs"]["data"].each do |l|
  printf "%-30s %s\n" % [ c["certname"].rstrip(), l["message"].split(/[\[,\]]/)[1] ] if l["message"].include?("#{resource}")
end
