class AddHomepageBannerContentBlock < ActiveRecord::Migration[5.1]
  def up
    ContentBlock.create(reference: 'homepage_banner', value: '')
  end

  def down
    ContentBlock.find_by(reference: 'homepage_banner').destroy
  end
end
