# frozen_string_literal: true
module RenderConstraintsHelper
  def missing_constraint_url(field_name)
    search_action_url(add_range_missing(field_name))
  end

  def missing_constraint_url_corrected(field_name)
    missing_url = missing_constraint_url(field_name)
    if missing_url.include?("&search_field=keyword")
      missing_url
    else
      "#{missing_url}&search_field=keyword"
    end
  end
end
