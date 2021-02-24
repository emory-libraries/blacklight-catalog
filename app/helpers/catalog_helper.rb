# frozen_string_literal: true
# [Blacklight-overwrite v7.4.1] Adds openurl helper methods for `getit` tab
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def openurl(mms_id, service = "viewit")
    url = openurl_base + "rfr_id=info:sid/primo.exlibrisgroup.com&u.ignore_date_coverage=true&svc_dat=#{service}&rft.mms_id=#{mms_id}"
    url += "&sso=true&token=#{session.id}" if current_user && current_user.provider == 'shibboleth'
    url
  end
end
