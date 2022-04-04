# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MoreOptionsHelper, type: :helper do
  before do
    delete_all_documents_from_solr
    build_solr_docs(
      [
        TEST_ITEM,
        TEST_ITEM.dup.merge(
          id: '456',
          format_ssim: ['Musical Score', 'Book']
        )
      ]
    )
  end
  let(:formats) { ::ExtractionTools::MARC_RESOURCE_FORMATS }
  let(:links_hash) do
    {
      formats[:music] => { 'Music and Scores' => 'music-media/materials/music-and-scores' },
      formats[:map] => { 'Maps' => 'woodruff/materials/maps' },
      formats[:visual] => [
        { 'Films and Videos' => 'materials/films-and-videos' }, { 'Images' => 'materials/images' }
      ],
      formats[:sound] => { 'Music and Scores' => 'music-media/materials/music-and-scores' },
      formats[:file] => { 'General Materials' => 'materials' },
      formats[:archival] => { 'Archives and Special Collections' => 'materials/archives-and-special-collections' },
      formats[:journal] => [
        { 'Journals and Newspapers' => 'node/1576' }, { 'Articles' => 'materials/articles' }
      ],
      formats[:book] => [
        { 'Books' => 'materials/books' }, { 'Audiobooks' => 'materials/audiobooks' },
        { 'Theses and Dissertations' => 'materials/electronic-theses-and-dissertations' }
      ]
    }
  end
  let(:solr_doc) { SolrDocument.find(TEST_ITEM[:id]) }
  let(:solr_doc2) { SolrDocument.find('456') }
  let(:expected_single_valued_string) do
    "<li class=\"list-group-item more-options\"><a href=\"https://libraries.emory.edu/materials/books\" " \
      "target=\"_blank\" rel=\"noopener noreferrer\" class=\"nav-link\">Find more information about Books" \
      "</a></li><li class=\"list-group-item more-options\"><a href=\"https://libraries.emory.edu/materials/audiobooks\" " \
      "target=\"_blank\" rel=\"noopener noreferrer\" class=\"nav-link\">Find more information about Audiobooks</a>" \
      "</li><li class=\"list-group-item more-options\"><a href=\"https://libraries.emory.edu/materials/" \
      "electronic-theses-and-dissertations\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"nav-link\">" \
      "Find more information about Theses and Dissertations</a></li>"
  end
  let(:expected_multivalued_string) do
    "<li class=\"list-group-item more-options\"><a href=\"https://libraries.emory.edu/music-media/materials/" \
      "music-and-scores\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"nav-link\">" \
      "Find more information about Music and Scores</a></li><li class=\"list-group-item more-options\">" \
      "<a href=\"https://libraries.emory.edu/materials/books\" target=\"_blank\" rel=\"noopener noreferrer\" " \
      "class=\"nav-link\">Find more information about Books</a></li><li class=\"list-group-item more-options\">" \
      "<a href=\"https://libraries.emory.edu/materials/audiobooks\" target=\"_blank\" rel=\"noopener noreferrer\" " \
      "class=\"nav-link\">Find more information about Audiobooks</a></li><li class=\"list-group-item more-options\">" \
      "<a href=\"https://libraries.emory.edu/materials/electronic-theses-and-dissertations\" target=\"_blank\" " \
      "rel=\"noopener noreferrer\" class=\"nav-link\">Find more information about Theses and Dissertations</a></li>"
  end

  it 'holds a global hash variable used for mapping' do
    expect(MoreOptionsHelper::MATERIAL_TYPE_PAGE_LINKS).to eq links_hash
  end

  context '#render_more_options_links' do
    it 'returns a single link wrapped in a list item tag when format_ssim has a single value' do
      expect(helper.render_more_options_links(solr_doc)).to eq(expected_single_valued_string)
    end

    it 'returns a two links wrapped in their own list item tags when format_ssim has two values' do
      expect(helper.render_more_options_links(solr_doc2)).to eq(expected_multivalued_string)
    end
  end
end
