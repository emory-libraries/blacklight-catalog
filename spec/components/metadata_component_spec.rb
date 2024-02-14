# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetadataComponent, type: :component do
  let(:view_context) { controller.view_context }

  let(:data) do
    { author_display_ssim: ['George Jenkins'],
      publication_main_display_ssim: ['A dummy publication'],
      format_ssim: ['Book'],
      edition_tsim: ['A sample edition'],
      local_call_number_tesim: ['MST .3000'],
      bound_with_display_ssim: ["{\"mms_id\":\"990029355560302486\",\"text\":\"Some Bound With Text.\"}"],
      isbn_ssim: ['SOME MAGICAL NUM .66G'],
      issn_ssim: ['SOME OTHER MAGICAL NUMBER .12Q'] }
  end

  let(:document) { SolrDocument.new(data) }

  let(:fields) do
    data.keys.map do |key|
      field_config = Blacklight::Configuration::Field.new(key: key.to_s, field: key.to_s, label: key.to_s)
      Blacklight::FieldPresenter.new(view_context, document, field_config)
    end
  end
  let(:rendered) { render_inline(component).to_s }

  context 'when a YAML config file is provided' do
    let(:component) { described_class.new(config: 'main_metadata.yml', fields:) }

    it 'renders all fields included in YAML file' do
      keys = YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'main_metadata.yml')))
      keys.each do |key, _|
        expect(rendered).to include data[key.to_sym].first
      end
    end

    it 'does not render fields not included in YAML file' do
      expect(rendered).not_to include 'SOME MAGICAL NUM .66G'
    end
  end

  context 'when no YAML config file is provided' do
    let(:component) { described_class.new(fields:) }

    it 'renders all fields in the document' do
      data.each do |_, v|
        expect(rendered).to include v.first
      end
    end
  end
end
