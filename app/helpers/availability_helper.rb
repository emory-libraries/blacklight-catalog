# frozen_string_literal: true
module AvailabilityHelper
  def render_physical_avail_spans(avail_values, mms_id)
    return if avail_values[:physical_holdings].blank?
    status = get_phys_avail_status(avail_values)
    label = phys_label_span(status)
    table_toggle_anchor = table_toggle_anch(mms_id)
    dt = tag.span(table_toggle_anchor, class: "phys-avail-button")

    safe_join([label, dt])
  end

  def phys_label_span(status)
    avail_class = get_avail_class(status)
    tag.span(status, class: "btn rounded-0 phys-avail-label #{avail_class}")
  end

  def table_toggle_anch(mms_id)
    tag.a('LOCATE',
            href: "#avail-#{mms_id}-toggle",
            data: { toggle: "collapse" },
            class: "btn btn-md rounded-0 btn-outline-primary avail-link-el")
  end

  def get_phys_avail_status(avail_values)
    avail_num = avail_count(avail_values)
    if avail_num.size > 1
      '1+ Available'
    elsif avail_num.size == 1
      'Available'
    elsif show_check_holdings?(avail_values, avail_num)
      'Check Holdings'
    else
      'Not Available'
    end
  end

  def get_avail_class(status)
    case status
    when "Check Holdings"
      'avail-unknown'
    when "Available", "1+ Available"
      'avail-success'
    else
      'avail-danger'
    end
  end

  def avail_count(avail_values)
    avail_values[:physical_holdings].select { |ph| ph[:status] == 'available' }
  end

  def show_check_holdings?(avail_values, avail_num)
    avail_num.size.zero? &&  avail_values[:physical_holdings].any? { |ph| ph[:status] == 'check_holdings' }
  end

  def raw_status_to_label(status)
    case status
    when 'available'
      "Available"
    when 'unavailable'
      "Not Available"
    when 'check_holdings'
      "Check Holdings"
    else
      "Not Available"
    end
  end

  def render_online_link_span(mms_id)
    tag.span(online_modal_link(mms_id), class: "online-avail-button")
  end

  def online_modal_link(mms_id)
    tag.a("CONNECT", href: "#", data: { toggle: 'modal', target: "#avail-modal-#{mms_id}" }, class: "btn btn-md rounded-0 mb-2 btn-outline-primary avail-link-el")
  end
end
