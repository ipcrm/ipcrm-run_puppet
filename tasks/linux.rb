#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'
require 'json'
require 'open3'

_param = STDIN.read

if _param.nil?  or _param == ''
  _noop = ''
else
  params = JSON.parse(_param)
  noop = params['noop']
  if noop =~ /true/i
    _noop = "--noop"
  elsif noop =~ /false/i
    _noop = "--no-noop"
  else
    raise("Unknown argument value for noop, [#{noop}]")
  end
end


begin
  cmd_string = "/opt/puppetlabs/bin/puppet agent -t #{_noop}"
  _,stdout,stderr,wait_thr = Open3.popen3(cmd_string)
  raise Puppet::Error, stderr if ([wait_thr.value.exitstatus] & [0,2]).empty?
  puts({ status: 'success', message: stdout.readlines.join(''), resultcode: wait_thr.value.exitstatus }.to_json)
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', message: "#{e.message}\n#{stderr.readlines.join('')}", resultcode: wait_thr.value.exitstatus }.to_json)
  exit 1
end
