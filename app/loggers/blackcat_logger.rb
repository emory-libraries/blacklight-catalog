# frozen_string_literal: true
class BlackcatLogger
  attr_writer :build_array

  def initialize
    @build_array = []
    @starting_time = Time.new.utc
  end

  def insert_title(title)
    @build_array << title
  end

  def pile_on(arr)
    @build_array += arr
  end

  def process_file(desired_filename)
    filename_with_time = "#{desired_filename}_#{@starting_time.strftime('%Y%m%dT%H%M')}"
    File.open(Rails.root.join('tmp', "#{filename_with_time}.log"), 'w+') do |f|
      f.puts(@build_array)
    end
  end
end
