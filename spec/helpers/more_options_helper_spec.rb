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
  let(:links_hash) do
    {
      "Musical Score" => { "Music and Scores" => "music-scores.html" },
      "Map" => { "General Materials" => "index.html" },
      "Video/Visual Material" => [
        { "Films and Videos" => "film-videos/index.html" },
        { "Images" => "images.html" }
      ],
      "Sound Recording" => { "Music and Scores" => "music-scores.html" },
      "Computer File" => { "General Materials" => "index.html" },
      "Archival Material/Manuscripts" => { "Archives and Special Collections" => "archives-special-collections.html" },
      "Journal, Newspaper or Serial" => [
        { "Journals and Newspapers" => "journals-newspapers.html" },
        { "Articles" => "articles.html" }
      ],
      "Book" => { "Books" => "books.html" }
    }
  end
  let(:solr_doc) { SolrDocument.find(TEST_ITEM[:id]) }
  let(:solr_doc2) { SolrDocument.find('456') }
  let(:expected_single_valued_string) do
    "<li class=\"list-group-item more-options\"><a href=\"https://libraries.emory.edu/materials/books.html\" " \
      "target=\"_blank\" rel=\"noopener noreferrer\" class=\"nav-link\">Find more information about Books</a></li>"
  end
  let(:expected_multivalued_string) do
    "<li class=\"list-group-item more-options\"><a href=\"https://libraries.emory.edu/materials/music-scores.html\" " \
      "target=\"_blank\" rel=\"noopener noreferrer\" class=\"nav-link\">Find more information about Music and Scores</a>" \
      "</li><li class=\"list-group-item more-options\"><a href=\"https://libraries.emory.edu/materials/books.html\" " \
      "target=\"_blank\" rel=\"noopener noreferrer\" class=\"nav-link\">Find more information about Books</a></li>"
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
