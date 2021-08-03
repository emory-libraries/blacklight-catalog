# frozen_string_literal: true
class ExportRisController < ApplicationController
  def export_multiple_ris
    text = ''
    params[:ids].split(',').each do |id|
      text += SolrDocument.find(id).send(:export_as_ris) + "\n"
    end

    respond_to do |format|
      format.any do
        send_data text, filename: 'multiple_bookmarks.ris'
      end
    end
  end
end
