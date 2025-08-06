#!/usr/bin/env ruby

# back up solr collection
# provide a listing of collections available for backup
# verify backup status


require 'net/http'
require 'json'
require 'socket'

class String
  def bold
    "\e[1m#{self}\e[22m" 
  end
end

def notify_slack(location, collection_name)
  size = "du -s #{location}"
  if size.empty? || size&.split("\t")&.first&.to_i < 300000
    channel = 'dlp-backups-failed-jobs'
    text = "#{collection_name} on solr prod had a problem backing up, please investigate"
  else
    channel = 'dlp-backups'
    text = "#{collection_name} on solr prod backed up successfully"
  end 
  webhook_url = 'https://hooks.slack.com/services/' + ENV['SLACK_HOOK']
  payload = { :channel => channel, :text => text }.to_json
  cmd = "curl -X POST --data-urlencode 'payload=#{payload}' #{webhook_url}"

  system(cmd)    
end

def prepare_uri(endpoint)
  uri           = URI.parse(endpoint)
  @response     = Net::HTTP.get_response(uri)
end

def status_report(request_id, backup_status)
  puts "status of #{request_id} is #{backup_status}"
end

def list_collections
  url           = "http://localhost:8983/solr/admin/collections?action=LIST"
  prepare_uri(url)
  puts "-- collections --"
  JSON.parse(@response.read_body)['collections'].each { |c| puts c }
end

def are_we_there_yet(backup_status, request_id)
  case backup_status
  when 'completed'
    status_report(request_id, backup_status)
  when 'notfound'
    puts "id not found"
  when 'running', 'submitted'
    status_report(request_id, backup_status)
    sleep(20)
    get_backup_status(request_id)
  else
    puts "undefined return code"
  end
end

def get_backup_status(request_id)
  url             = "http://localhost:8983/solr/admin/collections?action=REQUESTSTATUS&requestid=#{request_id}"
  uri             = URI.parse(url)
  response        = Net::HTTP.get_response(uri)
  backup_json     = JSON.parse(response.body)
  backup_status   = backup_json['status']['state']
  are_we_there_yet(backup_status, request_id)
end

def right_now
  Time.now.strftime("%Y%m%d%H%M")
end

def short_hostname
  short_host = Socket.gethostname.split('.')[0]
  case short_host
  when 'solr-cor-1'
    "prod"
  when 'solr-cor-arch-1'
    "arch"
  when 'solr-cor-test-1'
    "test"
  else
    abort("undefined host")
  end
end

def print_runtime_options
  puts "Exiting -- one arg required!".bold
  puts "Usage -- `ruby #{__FILE__} <collection_for_backup>"
  puts "enter `ruby #{__FILE__} collections` to get a listing."
  exit 1
end

def perform_backup
  if ARGV.length < 1
    print_runtime_options
  elsif ARGV[0] == 'collections'
    list_collections
    exit 2
  else
    item        = ARGV[0]
    request_id  = "#{item}_backup_#{right_now}"
    url         = "http://localhost:8983/solr/admin/collections?action=BACKUP&collection=#{item}&location=/mnt/#{short_hostname}_efs/solr/backup/&name=#{item}_backup_#{right_now}&async=#{request_id}"
    location    = "/mnt/#{short_hostname}_efs/solr/backup/#{item}_backup_#{right_now}"

    prepare_uri(url)
    get_backup_status(request_id)
    notify_slack(location, item) if short_hostname == 'prod'
  end
end

perform_backup
