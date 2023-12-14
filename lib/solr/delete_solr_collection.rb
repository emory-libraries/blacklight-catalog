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

def prepare_uri(endpoint)
  uri           = URI.parse(endpoint)
  @response     = Net::HTTP.get_response(uri)
end

def print_runtime_options
  puts "USAGE: ruby #{__FILE__} <collection_to_delete>".bold
  puts "or run `ruby #{__FILE__} collections` to get a listing of existing collections."
end

def list_collections
  url           = "http://localhost:8983/solr/admin/collections?action=LIST"
  prepare_uri(url)
  puts "-- collections --"
  JSON.parse(@response.read_body)['collections'].each { |c| puts c }
end

def is_error?(response)
  JSON.parse(response)['responseHeader']['status'] == 500
end

def check_http_response(response)
  if is_error?(response.body)
    puts "500 ERROR: server reply was: #{JSON.parse(response.body)['exception']['msg']}".bold
  else
    puts "response: #{JSON.parse(response.body)}"
  end
end

def delete_collection
  if ARGV[0] == 'collections'
    list_collections
    exit 1
  elsif ARGV.length < 1
    print_runtime_options
    exit 2
  else
    collection  = ARGV[0]
    url = "http://localhost:8983/solr/admin/collections?action=DELETE&name=#{collection}&wt=json"
    prepare_uri(url)
    check_http_response(@response)
  end
end

delete_collection
list_collections
