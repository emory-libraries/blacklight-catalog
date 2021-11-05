# frozen_string_literal: true

##
# Helpers for the AlternateCatalog feature
module AlternateCatalogHelper
  def show_alternate_catalog?
    return true if params.fetch(:q, nil).present?

    false
  end

  def rounded_lightbulb
    tag.div(
      tag.span(image_tag("lightbulb.svg", height: "32", width: "32"), class: "rounded-lightbulb"),
      class: "lightbulb"
    )
  end
end
