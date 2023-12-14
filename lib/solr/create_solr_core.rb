#!/usr/env/bin ruby


require 'net/http'
require 'json'

class String
  def bold
    "\e[1m#{self}\e[22m"
  end
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

def list_cores
  url             =  "http://localhost:8983/solr/admin/cores?action=STATUS"
  prepare_uri(url)
  cores           = JSON.parse(@response.read_body)
  cores_names     = cores['status']
  puts cores_names.keys      
end

def prepare_uri(endpoint)
  uri           = URI.parse(endpoint)
  @response     = Net::HTTP.get_response(uri)
end

def print_runtime_options
  puts "USAGE: ruby #{__FILE__} <core to create> <path to config file> <path to schema file> "
  puts "or run `ruby #{__FILE__} cores` to get a listing of existing cores"
end

def create_core
  if ARGV[0] == 'cores'
    list_cores
    exit 1
  elsif ARGV.length < 3
    print_runtime_options
    exit 2
  else
    core_name = ARGV[0]
    core_config = ARGV[1]
    schema_config = ARGV[2]
    core_url = "http://localhost:8983/solr/admin/cores?action=CREATE&name=#{core_name}&instanceDir=/opt/data/solr/data/testing/&collection=#{core_name}"
   prepare_uri(collection_url)
    check_http_response(@response)

    prepare_uri(core_url)
    check_http_response(@response)
    
  end
end

create_core
