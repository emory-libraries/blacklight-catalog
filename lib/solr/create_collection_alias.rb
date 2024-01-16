#!/usr/bin/env ruby

# create alias for a solr collection
# print alias listing
# provide option for listing collections

require 'net/http'
require 'json'

class String
  def bold
    "\e[1m#{self}\e[22m" 
  end
end

def loop_aliases(jaliases, nalias)
  jaliases['aliases'].each do |new_alias, collection|
    if new_alias == nalias
      puts "#{new_alias} is an alias of #{collection}".bold
    else
      puts "#{new_alias} is an alias of #{collection}"
    end
  end
end

def prepare_uri(endpoint)
  uri           = URI.parse(endpoint)
  @response     = Net::HTTP.get_response(uri)
end

def list_collections
  url           = "http://localhost:8983/solr/admin/collections?action=LIST"
  prepare_uri(url)
  JSON.parse(@response.read_body)['collections'].each { |c| puts c }
end

def verify_new_alias(nalias='')
  url             =  "http://localhost:8983/solr/admin/collections?action=LISTALIASES"
  prepare_uri(url)
  jaliases        = JSON.parse(@response.read_body)
  loop_aliases(jaliases, nalias)
end

def print_runtime_options
  puts "two args required! -- USAGE: ruby #{__FILE__} <new_alias_name> <collection_to_be_aliased>".bold
  puts "run the command `ruby #{__FILE__} collections` to get a listing of availble collections"
  puts "or run `ruby #{__FILE__} aliases` to get a listing of existing aliases"
end

def create_new_alias
  if ARGV[0] == 'collections'
    list_collections
    exit 1
  elsif ARGV[0] == 'aliases'
    verify_new_alias()
    exit 2
  elsif ARGV.length < 2
    print_runtime_options
    exit 3
  else
    new_alias   = ARGV[0]
    collection  = ARGV[1]
    url         = "http://localhost:8983/solr/admin/collections?action=CREATEALIAS&name=#{new_alias}&collections=#{collection}&wt=xml"
    prepare_uri(url)
    verify_new_alias(new_alias)
  end
end

create_new_alias
