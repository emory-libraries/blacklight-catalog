# frozen_string_literal: true
module ApplicationHelper
  def openurl_base
    "https://#{ENV['ALMA']}.alma.exlibrisgroup.com/view/uresolver/#{ENV['INSTITUTION']}/openurl?"
  end
end
