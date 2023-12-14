#!/usr/env/bin ruby

# delete a solr collection alias
# provide option for listing aliases

require 'net/http'
require 'json'

class String
  def bold
    "\e[1m#{self}\e[22m"
  end
end

def loop_aliases(jaliases)
  puts "-- collection aliases --"
  jaliases['aliases'].each { |new_alias, collection| puts "#{new_alias} is an alias of #{collection}" }
end

def list_aliases
  url             =  "http://localhost:8983/solr/admin/collections?action=LISTALIASES"
  prepare_uri(url)
  jaliases        = JSON.parse(@response.read_body)
  loop_aliases(jaliases)
end

def prepare_uri(endpoint)
  uri           = URI.parse(endpoint)
  @response     = Net::HTTP.get_response(uri)
end

def print_runtime_options
  puts "USAGE: ruby #{__FILE__} <alias_to_delete>".bold
  puts "or run `ruby #{__FILE__} aliases` to get a listing of existing aliases"
end

def delete_alias
  if ARGV[0] == 'aliases'
    list_aliases
    exit 1
  elsif ARGV.length < 1
    print_runtime_options
    exit 2
  else
    target_alias = ARGV[0]
    url = "http://localhost:8983/solr/admin/collections?action=DELETEALIAS&name=#{target_alias}&wt=xml"
    prepare_uri(url)
  end
end

delete_alias
list_aliases
