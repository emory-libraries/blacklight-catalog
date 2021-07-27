# frozen_string_literal: true

class UpdateCollectionAuthorityService
  def self.update_authority_entries
    response = RestClient.get "#{ENV['SOLR_URL']}/select?fl=collection_ssim&facet.field=collection_ssim&facet.limit=-1&facet=true"
    json_response = JSON.parse(response.body)
    collections = json_response["facet_counts"]["facet_fields"]["collection_ssim"]
    collections = collections&.delete_if { |n| n.is_a? Integer }
    Qa::LocalAuthorityEntry.delete_all
    collection_auth = Qa::LocalAuthority.find_or_create_by(name: 'collections')
    collections&.each do |col|
      Qa::LocalAuthorityEntry.create(local_authority: collection_auth, uri: col)
    end
  end
end
