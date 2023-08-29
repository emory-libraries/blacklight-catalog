# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SearchResultsHelper, type: :helper do
  describe "#ejournals_search_params" do
    it "generates correct search parameters with letter" do
      state = {}
      letter = "A"
      expected_params = {
        controller: "catalog",
        action: "index",
        search_field: "advanced",
        commit: "Search",
        utf8: "✓",
        sort: "title_ssort asc, pub_date_isim desc",
        f: {
          marc_resource_ssim: ["Online"],
          format_ssim: ["Journal, Newspaper or Serial"],
          title_main_first_char_ssim: ["A"]
        }
      }

      result = helper.ejournals_search_params(state:, letter:)
      expect(result).to eq(expected_params)
    end

    it "generates correct search parameters without letter" do
      state = {}
      expected_params = {
        controller: "catalog",
        action: "index",
        search_field: "advanced",
        commit: "Search",
        utf8: "✓",
        sort: "title_ssort asc, pub_date_isim desc",
        f: {
          marc_resource_ssim: ["Online"],
          format_ssim: ["Journal, Newspaper or Serial"]
        }
      }

      result = helper.ejournals_search_params(state:)
      expect(result).to eq(expected_params)
    end
  end

  describe "#title_starts_with_search_params" do
    it "generates correct search parameters with letter" do
      state = { f: { language_ssim: ["English"] } }
      letter = "B"
      expected_params = {
        sort: "title_ssort asc, pub_date_isim desc",
        f: {
          language_ssim: ["English"],
          title_main_first_char_ssim: ["B"]
        }
      }

      result = helper.title_starts_with_search_params(state:, letter:)
      expect(result).to eq(expected_params)
    end

    it "generates correct search parameters without letter" do
      state = { f: { language_ssim: ["English"] } }
      expected_params = {
        sort: "title_ssort asc, pub_date_isim desc",
        f: { language_ssim: ["English"] }
      }

      result = helper.title_starts_with_search_params(state:)
      expect(result).to eq(expected_params)
    end
  end

  describe "#active_letter" do
    it "returns active letter when present in state" do
      state = { f: { title_main_first_char_ssim: ["C"] } }
      expect(helper.active_letter(state)).to eq("C")
    end

    it "returns nil when active letter is not present in state" do
      state = { f: { language_ssim: ["English"] } }
      expect(helper.active_letter(state)).to be_nil
    end

    it "returns nil when facets are not present in state" do
      state = {}
      expect(helper.active_letter(state)).to be_nil
    end
  end
end
