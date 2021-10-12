# frozen_string_literal: true

module MoreOptionsHelper
  formats = ::ExtractionTools::MARC_RESOURCE_FORMATS
  MATERIAL_TYPE_PAGE_LINKS = {
    formats[:music] => { 'Music and Scores': 'music-scores.html' },
    formats[:map] => { 'General Materials': 'index.html' },
    formats[:visual] => [
      { 'Films and Videos': 'film-videos/index.html' }, { 'Images': 'images.html' }
    ],
    formats[:sound] => { 'Music and Scores': 'music-scores.html' },
    formats[:file] => { 'General Materials': 'index.html' },
    formats[:archival] => { 'Archives and Special Collections': 'archives-special-collections.html' },
    formats[:journal] => [
      { 'Journals and Newspapers': 'journals-newspapers.html' }, { 'Articles': 'articles.html' }
    ],
    formats[:book] => { 'Books': 'books.html' }
  }.with_indifferent_access.freeze

  def render_more_options_links(document)
    link_el_hashes = document.more_options.map { |v| MATERIAL_TYPE_PAGE_LINKS[v] }.flatten
    links = link_el_hashes.map do |h|
      tag.li(
        tag.a(t('catalog.show.find_more_info') + h.keys[0],
          href: "https://libraries.emory.edu/materials/#{h.values[0]}",
          target: '_blank',
          rel: 'noopener noreferrer',
          class: 'nav-link'),
        class: "list-group-item more-options"
      )
    end
    return safe_join(links, '') if links.present?
    ''
  end
end
