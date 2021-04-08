# frozen_string_literal: true
class OaiMmsidLogger < BlackcatLogger
  def initialize
    super
    insert_title("Log of deleted, suppressed, and active records' MMS ids")
  end

  def announce_batch(batch_num, token)
    @build_array << "Batch ##{batch_num}, query string: #{token}"
  end

  def announce_ids(type_str)
    @build_array << "#{type_str} Record IDs"
  end
end
