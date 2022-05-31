# frozen_string_literal: true

xml.supplemental_link do
  link_pieces = supp.split(' text: ')
  xml.link link_pieces.first
  xml.label link_pieces.size > 1 ? link_pieces[1] : link_pieces.first
end
