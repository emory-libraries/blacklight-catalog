# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User do
  let(:user_with_uid) { described_class.new(uid: 'user123') }
  context 'omniauthable user' do
    it "has a uid field" do
      expect(user_with_uid.uid).not_to be_empty
    end
    it "can have a provider" do
      expect(user_with_uid.respond_to?(:provider)).to eq true
    end
  end

  context "shibboleth integration" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'shibboleth',
        uid: "janeq",
        info: {
          display_name: "Jane Quest",
          uid: 'janeq',
          mail: 'janeq@emory.edu'
        }
      )
    end

    before do
      described_class.destroy_all
    end

    context "shibboleth" do
      let(:user) { described_class.from_omniauth(auth_hash) }
      it "has a shibboleth provided name" do
        expect(user.display_name).to eq auth_hash.info.display_name
      end
      it "has a shibboleth provided uid which is not nil" do
        expect(user.uid).to eq auth_hash.info.uid
        expect(user.uid).not_to eq nil
      end
      it "has a shibboleth provided email which is not nil" do
        expect(user.email).to eq auth_hash.info.mail
        expect(user.email).not_to eq nil
      end
    end
    context "alma" do
      let(:user) { described_class.from_omniauth(auth_hash) }
      around do |example|
        orig_url = ENV['ALMA_API_URL']
        orig_key = ENV['ALMA_USER_KEY']
        ENV['ALMA_API_URL'] = 'http://www.example.com'
        ENV['ALMA_USER_KEY'] = "fakeuserkey456"
        example.run
        ENV['ALMA_API_URL'] = orig_url
        ENV['ALMA_USER_KEY'] = orig_key
      end

      it "has a user group from alma" do
        stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
          .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record.xml'), headers: {})
        expect(user.uid).to eq "janeq"
        expect(user.user_group).to eq "03"
        expect(user.oxford_user?).to eq false
      end

      it "has an oxford user group from alma" do
        stub_request(:get, "http://www.example.com/almaws/v1/users/janeq?user_id_type=all_unique&view=full&expand=none&apikey=fakeuserkey456")
          .to_return(status: 200, body: File.read(fixture_path + '/alma_users/full_user_record_oxford.xml'), headers: {})
        expect(user.uid).to eq "janeq"
        expect(user.user_group).to eq "23"
        expect(user.oxford_user?).to eq true
      end
    end
  end
end
