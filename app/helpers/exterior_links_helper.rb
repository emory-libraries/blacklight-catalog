# frozen_string_literal: true
module ExteriorLinksHelper
  def service_page_url(doc_id)
    "#{ENV['ALMA_BASE_URL']}/discovery/openurl?institution=#{ENV['INSTITUTION']}&vid=#{ENV['INSTITUTION']}:services&rft.mms_id=#{doc_id}"
  end

  def databases_url
    'https://guides.libraries.emory.edu/az.php'
  end

  def articles_plus_url
    'https://emory.primo.exlibrisgroup.com/discovery/search?vid=01GALI_EMORY:articles'
  end

  def articles_plus_url_builder(search_state)
    state_query = search_state.to_h['q']
    "https://emory.primo.exlibrisgroup.com/discovery/search?vid=01GALI_EMORY:articles&query=any,contains,#{state_query}&lang=en"
  end

  def my_library_card_url
    'https://emory.primo.exlibrisgroup.com/discovery/account?vid=01GALI_EMORY:services&section=overview&lang=en'
  end

  def alma_social_login_url(redirect_to: nil)
    raise "alma_social_login_callback_url not setup" unless respond_to? :alma_social_login_callback_url
    callback_url = alma_social_login_callback_url
    alma_domain = "#{ENV['ALMA']}.alma.exlibrisgroup.com"

    callback_url = process_redirect_url(redirect_to, callback_url) if redirect_to

    query = { institutionCode: ENV["INSTITUTION"], backUrl: callback_url }

    URI::HTTPS.build(
      host: alma_domain,
      path: "/view/socialLogin",
      query: query.to_query
    ).to_s
  end

  private

  def process_redirect_url(redirect_to, callback_url)
    parsed_callback_url = URI.parse(callback_url)
    redirect_url = URI.decode_www_form(parsed_callback_url.query || "") << ["redirect_to", redirect_to]
    parsed_callback_url.query = URI.encode_www_form(redirect_url)
    parsed_callback_url.to_s
  end
end
