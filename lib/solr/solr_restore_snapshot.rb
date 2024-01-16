#!/usr/bin/env ruby

# takes a command line arg for a collection name to restore, then restores it

require 'net/http'
require 'json'
require 'socket'

def status_report(backup_status)
  puts "status of replication restore is #{backup_status}"
end


def are_we_there_yet(backup_status, collection)
  case backup_status
  when "success"
    status_report(backup_status)
  when "In Progress"
    status_report( backup_status)
    sleep(20)
    backup_status(collection)
  when "failed"
    status_report(backup_status)
  else
    puts "undefined return code"
  end
end

def backup_status(collection)
  url             = "http://localhost:8983/solr/#{collection}/replication?command=restorestatus"
  uri             = URI.parse(url)
  response        = Net::HTTP.get_response(uri)
  backup_json     = JSON.parse(response.body)
  backup_status   = backup_json['restorestatus']['status']
  are_we_there_yet(backup_status, collection)
end

#returns 'arch', 'test', etc.
def short_hostname
 Socket.gethostname.split('.')[0].split('-')[2]
end



def check_args
  if ARGV.length < 1
    puts "Exiting -- Please enter a backup to restore."
    puts "A backed-up collection name looks something like 'snapshot.blackcat_collection_202106010521'"
    puts "enter 'ls -ltr /mnt/#{short_hostname}_efs/solr/transfer.' to get a listing."
    exit 1
  end
  if ARGV.length < 2
    puts "Exiting -- Please enter a collection  to restore into"
    puts "visit https://solr-cor-#{short_hostname}.library.emory.edu/solr' to see options"
    exit 1
  end
end

def restore_collection
  backup      = ARGV[0]
  collection  = ARGV[1]
  puts "Preparing to restore #{backup} into #{collection}"
  url             =  "http://localhost:8983/solr/#{collection}/replication?command=RESTORE&name=#{backup}&location=/mnt/#{short_hostname}_efs/solr/transfer/"
  uri             = URI.parse(url)
  response        = Net::HTTP.get_response(uri)
  restore_json    = JSON.parse(response.body)
  backup_status(collection)
end

check_args
restore_collection
