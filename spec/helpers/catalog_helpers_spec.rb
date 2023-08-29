# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogHelper, type: :helper do
  let(:value) { SHOW_PAGE_VALUE }
  let(:multivalue) do
    dupe = SHOW_PAGE_VALUE.dup
    dupe[:document][dupe[:field]] = 'http://www.example.com', 'http://www.example.com/2'
    dupe
  end
  let(:multivalue_with_text) do
    dupe = SHOW_PAGE_VALUE.dup
    dupe[:document][dupe[:field]] = "http://www.example.com text: This is the link's text, bro", "http://www.example.com/2 text: Bro, this link's got text, too"
    dupe
  end

  context '#generic_solr_value_to_url' do
    it 'converts a single value to an anchor tag' do
      expect(helper.generic_solr_value_to_url(value)).to eq(
        "<a href=\"http://www.example.com\" target=\"_blank\" rel=\"noopener noreferrer\">http://www.example.com</a>"
      )
    end

    it 'converts a multiple values into two anchor tags separated by a breakline' do
      expect(helper.generic_solr_value_to_url(multivalue)).to eq(
        "<a href=\"http://www.example.com\" target=\"_blank\" rel=\"noopener noreferrer\">http://www.example.com</a>" \
          "<br><a href=\"http://www.example.com/2\" target=\"_blank\" rel=\"noopener noreferrer\">http://www.example.com/2</a>"
      )
    end

    it 'converts a multiple values into two anchor tags separated by a breakline and plucks text' do
      expect(helper.generic_solr_value_to_url(multivalue_with_text)).to eq(
        "<a href=\"http://www.example.com\" target=\"_blank\" rel=\"noopener noreferrer\">" \
          "This is the link&#39;s text, bro</a><br><a href=\"http://www.example.com/2\" target=\"_blank\" " \
          "rel=\"noopener noreferrer\">Bro, this link&#39;s got text, too</a>"
      )
    end
  end

  context '#multiple_values_new_line' do
    it 'converts a multiple values into two values separated by a breakline' do
      expect(helper.multiple_values_new_line(multivalue)).to eq(
        "http://www.example.com<br>http://www.example.com/2"
      )
    end
  end

  context '#author_additional_format' do
    let(:value) do
      dupe = SHOW_PAGE_VALUE.dup
      dupe[:value] = ["Tim Jenkins"]
      dupe
    end
    let(:value_with_relator) do
      dupe = SHOW_PAGE_VALUE.dup
      dupe[:value] = ["Tim Jenkins relator: editor."]
      dupe
    end
    let(:value_with_6_auth_addl) do
      dupe = SHOW_PAGE_VALUE.dup
      dupe[:value] = [
        "Tim Jenkins relator: editor.",
        "Sally Jenkins",
        "Betsy Jenkins",
        "Sal Weitzman relator: ghost writer.",
        "Mike Birbiglia",
        "Tim Conway relator: moral support."
      ]
      dupe
    end

    it 'converts a single valued additional author into a facet search hyperlink' do
      expect(helper.author_additional_format(value)).to eq(
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Tim+Jenkins\">Tim Jenkins</a>"
      )
    end

    it 'converts a single valued additional author with relator into a facet search hyperlink, leaving relator out of the link' do
      expect(helper.author_additional_format(value_with_relator)).to eq(
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Tim+Jenkins\">Tim Jenkins</a>, editor."
      )
    end

    it 'converts a values array with more than 5 items into a new-lined list with a collapsible after 5' do # rubocop:disable RSpec/ExampleLength
      expect(helper.author_additional_format(value_with_6_auth_addl)).to eq(
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Tim+Jenkins\">Tim Jenkins</a>, editor.<br>" \
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Sally+Jenkins\">Sally Jenkins</a><br>" \
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Betsy+Jenkins\">Betsy Jenkins</a><br>" \
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Sal+Weitzman\">Sal Weitzman</a>, ghost writer.<br>" \
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Mike+Birbiglia\">Mike Birbiglia</a><br>" \
        "<span id=\"extended-author-addl\" class=\"collapse collapsible-addl-authors\">" \
        "<a href=\"/?f%5Bauthor_addl_ssim%5D%5B%5D=Tim+Conway\">Tim Conway</a>, moral support.</span><br>" \
        "<a class=\"btn btn-link additional-authors-collapse collapsed\" data-toggle=\"collapse\"" \
        " role=\"button\" aria-expanded=\"false\" aria-controls=\"extended-author-addl\" href=\"#extended-author-addl\"></a>"
      )
    end # rubocop:enable RSpec/ExampleLength
  end

  context '#multilined_links_to_title_search' do
    let(:value) { SHOW_PAGE_VALUE.dup.merge(field: "title_former_ssim") }
    let(:later_value) { SHOW_PAGE_VALUE.dup.merge(field: "title_later_ssim") }
    let(:multi_value) do
      dupe = SHOW_PAGE_VALUE.dup
      dupe[:field] = "title_former_ssim"
      dupe[:document]["title_former_ssim"] = [
        "Contemporary keyboard 0361-5820 (DLC) 76641315 (OCoLC)2246955",
        "Music technology buyer's guide 1099-2839"
      ]
      dupe
    end
    let(:value_no_format) do
      dupe = SHOW_PAGE_VALUE.dup
      dupe[:field] = "title_former_ssim"
      dupe[:document]["format_ssim"] = []
      dupe[:document]["title_former_ssim"] = ["Music technology buyer's guide 1099-2839"]
      dupe
    end
    let(:value_empty) do
      dupe = SHOW_PAGE_VALUE.dup
      dupe[:field] = "title_former_ssim"
      dupe[:document]["title_former_ssim"] = []
      dupe
    end

    it 'processes a record value to link to a title search (former)' do
      expect(helper.multilined_links_to_title_search(value)).to eq(
        "<a href=\"/?f%5Bformat_ssim%5D%5B%5D=Book&amp;q=Contemporary+keyboard+" \
        "0361-5820+%28DLC%29+76641315+%28OCoLC%292246955&amp;search_field=title\">" \
        "Contemporary keyboard 0361-5820 (DLC) 76641315 (OCoLC)2246955</a>"
      )
    end

    it 'processes a record value to link to a title search (later)' do
      expect(helper.multilined_links_to_title_search(later_value)).to eq(
        "<a href=\"/?f%5Bformat_ssim%5D%5B%5D=Book&amp;q=Music+technology+buyer%27s" \
        "+guide+1099-2839&amp;search_field=title\">Music technology buyer&#39;s " \
        "guide 1099-2839</a>"
      )
    end

    it 'processes multiple record values to links to title search (former)' do
      expect(helper.multilined_links_to_title_search(multi_value)).to eq(
        "<a href=\"/?f%5Bformat_ssim%5D%5B%5D=Book&amp;q=Contemporary+keyboard+0361-5820" \
        "+%28DLC%29+76641315+%28OCoLC%292246955&amp;search_field=title\">Contemporary" \
        " keyboard 0361-5820 (DLC) 76641315 (OCoLC)2246955</a><br><a href=\"/?f%5B" \
        "format_ssim%5D%5B%5D=Book&amp;q=Music+technology+buyer%27s+guide+1099-2839&amp;" \
        "search_field=title\">Music technology buyer&#39;s guide 1099-2839</a>"
      )
    end

    it 'processes a record value to link to title search (former) with no format assigned' do
      expect(helper.multilined_links_to_title_search(value_no_format)).to eq(
        "<a href=\"/?q=Music+technology+buyer%27s+guide+1099-2839&amp;search_field=title\">" \
        "Music technology buyer&#39;s guide 1099-2839</a>"
      )
    end

    it 'returns nothing when field empty' do
      expect(helper.multilined_links_to_title_search(value_empty)).to be_empty
    end
  end
end
