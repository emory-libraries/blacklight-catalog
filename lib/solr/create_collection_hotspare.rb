#!/usr/bin/env ruby

require 'net/http'
require 'json'

class CreateCollectionHotSpare
  SOLR_BASE_URL = 'http://localhost:8983/solr'.freeze

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

  def latest_backup_file
    backup_folder = "/mnt/#{short_hostname}_efs/solr/backup"
    file_prefix = "#{@source_collection}_backup"
    matches = Dir.entries(backup_folder).select { |f| f.start_with?(file_prefix)}
    matches.max_by { |f| File.mtime(File.join(backup_folder, f)) }
  end

  def get_backup_status(request_id)
    max_duration = 1800
    start_time = Time.now
    status = nil

    loop do
      if Time.now - start_time > max_duration
        puts "Creating a hot spare for collection #{@source_collection} exceeded maximum duration"
        return
      elsif status == 'completed'
        puts "Creating a hot spare for collection #{@source_collection} succeeded"
        return   
      end
      
      begin
        url = "#{SOLR_BASE_URL}/admin/collections?action=REQUESTSTATUS&requestid=#{request_id}"
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        
        if response.is_a?(Net::HTTPSuccess)
          json = JSON.parse(response.body)
          status = json['status']['state']
          puts "Status of request #{request_id} is: #{status}"
        else
          puts "Error: #{response.code} - #{response.message}"
        end
      rescue StandardError => e
        puts "Error: #{e.message}"
      end
      
      sleep 10
    end
  end

  def print_runtime_options
    puts "Exiting -- argument <collection> required!"
    puts "Usage -- `ruby #{__FILE__} <collection>"
    exit 1
  end

  def delete_hotspare_collection
    url = "#{SOLR_BASE_URL}/admin/collections?action=DELETE&name=#{@hotspare_collection}"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri) 
    puts "Deleted hot spare collection: #{@hotspare_collection}" if response.is_a?(Net::HTTPSuccess)
  end

  def create_hotspare_collection
    request_id = "create_#{@hotspare_collection}_#{Time.now.strftime("%Y%m%d%H%M")}"
    url = "#{SOLR_BASE_URL}/admin/collections?action=RESTORE&name=#{latest_backup_file}&location=/mnt/#{short_hostname}_efs/solr/backup/&collection=#{@hotspare_collection}&async=#{request_id}"
    uri = URI.parse(url)
    Net::HTTP.get_response(uri)
    get_backup_status(request_id)
  end 

  def run
    puts "-- Running CreateCollectionHotSpare script --"
    
    if ARGV.length < 1
      print_runtime_options
      return
    end
    
    @source_collection = ARGV[0]
    @hotspare_collection = "#{@source_collection}_hotspare"
    delete_hotspare_collection
    create_hotspare_collection
    puts "-- Done --"
  end
end

CreateCollectionHotSpare.new.run
