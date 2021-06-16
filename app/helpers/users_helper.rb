# frozen_string_literal: true

module UsersHelper
  def alma_social_login_url
    raise "alma_social_login_callback_url not setup" unless respond_to? :alma_social_login_callback_url
    callback_url = alma_social_login_callback_url

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
