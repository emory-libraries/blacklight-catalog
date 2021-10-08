# frozen_string_literal: true

require 'spec_helper'

describe AlternateCatalogHelper do
  describe 'show_alternate_catalog?' do
    context 'with q params' do
      it do
        controller.params[:q] = 'query'
        expect(helper.show_alternate_catalog?).to eq true
      end
    end

    context 'no q params' do
      it do
        expect(helper.show_alternate_catalog?).to eq false
      end
    end
  end
end
