#!/usr/bin/env ruby

# takes a command line arg for a collection name to restore, then restores it

require 'net/http'
require 'json'
require 'socket'

# returns 'arch', 'test', etc.
def short_hostname
 Socket.gethostname.split('.')[0].split('-')[2]
end

def check_args
  if ARGV.length < 1
    puts "Exiting -- Please enter a collection to restore."
    puts "A backed-up collection name looks something like 'blackcat_collection_backup_202106010521'"
    puts "enter 'ls -ltr /mnt/#{short_hostname}_efs/solr/backup' to get a listing."
    exit 1
  end
end

def restore_collection
  collection      = ARGV[0]
  puts "Preparing to restore #{collection}."
  url             =  "http://localhost:8983/solr/admin/collections?action=RESTORE&name=#{collection}&location=/mnt/#{short_hostname}_efs/solr/backup/&collection=#{collection}_restored"
  uri             = URI.parse(url)
  response        = Net::HTTP.get_response(uri)
  restore_json    = JSON.parse(response.body)
  puts "Done. Please verify restored collection in ~:8983/solr/admin => collections.\n"
  puts restore_json
end

check_args
restore_collection
