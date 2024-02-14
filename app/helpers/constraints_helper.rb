# frozen_string_literal: true
module ConstraintsHelper
  # Blacklight v7.4.2
  # app/helpers/blacklight/render_constraints_helper_behavior.rb
  # Render the facet constraints
  # @param [Hash] localized_params query parameters
  # @return [String]
  def render_constraints_filters(localized_params = params)
    return "".html_safe unless localized_params[:f]

    path = controller.search_state_class.new(localized_params, blacklight_config, controller)
    content = []
    localized_params[:f].each_pair do |facet, values|
      content << render_filter_element(facet, values, path)
    end

    safe_join(content.flatten, "\n")
  end
end
