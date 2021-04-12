# frozen_string_literal: true
module MoreOptionsHelper
  MATERIAL_TYPE_PAGE_LINKS = {
    'Musical Score': { 'Music and Scores': 'music-scores.html' },
    'Map': { 'General Materials': 'index.html' },
    'Video/Visual Material': [
      { 'Films and Videos': 'film-videos/index.html' }, { 'Images': 'images.html' }
    ],
    'Sound Recording': { 'Music and Scores': 'music-scores.html' },
    'Computer File': { 'General Materials': 'index.html' },
    'Archival Material/Manuscripts': { 'Archives and Special Collections': 'archives-special-collections.html' },
    'Journal, Newspaper or Serial': [
      { 'Journals and Newspapers': 'journals-newspapers.html' }, { 'Articles': 'articles.html' }
    ],
    'Book': { 'Books': 'books.html' }
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
