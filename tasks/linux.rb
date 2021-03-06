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

cmd_string = "/opt/puppetlabs/bin/puppet agent -t #{_noop}"
_,stdout,stderr,wait_thr = Open3.popen3(cmd_string)

if !([wait_thr.value.exitstatus] & [0,2]).empty?
  puts({ status: 'success', message: stdout.readlines, resultcode: wait_thr.value.exitstatus }.to_json)
  exit 0
else
  puts({ status: 'failure', message: stdout.readlines + stderr.readlines, resultcode: wait_thr.value.exitstatus }.to_json)
  exit wait_thr.value.exitstatus
end
