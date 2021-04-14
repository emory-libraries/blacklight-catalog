# frozen_string_literal: true

require_relative '../prepends/custom_citation_logic'

Blacklight::Solr::Document::MarcExport.prepend(CustomCitationLogic)
