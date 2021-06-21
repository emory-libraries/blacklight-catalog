# frozen_string_literal: true

module UsersHelper
  def alma_social_login_url(redirect_to: nil)
    raise "alma_social_login_callback_url not setup" unless respond_to? :alma_social_login_callback_url
    callback_url = alma_social_login_callback_url

    if redirect_to
      parsed_callback_url = URI.parse(callback_url)
      redirect_url = URI.decode_www_form(parsed_callback_url.query || "") << ["redirect_to", redirect_to]
      parsed_callback_url.query = URI.encode_www_form(redirect_url)
      callback_url = parsed_callback_url.to_s
    end

    query = {
      institutionCode: ENV["INSTITUTION"],
      backUrl: callback_url
    }

    alma_domain = "#{ENV['ALMA']}.alma.exlibrisgroup.com"

    URI::HTTPS.build(
      host: alma_domain,
      path: "/view/socialLogin",
      query: query.to_query
    ).to_s
  end
end
