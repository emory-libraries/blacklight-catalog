# frozen_string_literal: true

module MoreOptionsHelper
  formats = ::ExtractionTools::MARC_RESOURCE_FORMATS
  MATERIAL_TYPE_PAGE_LINKS = {
    formats[:music] => { 'Music and Scores': 'music-media/materials/music-and-scores' },
    formats[:map] => { 'Maps': 'woodruff/materials/maps' },
    formats[:visual] => [
      { 'Films and Videos': 'materials/films-and-videos' }, { 'Images': 'materials/images' }
    ],
    formats[:sound] => { 'Music and Scores': 'music-media/materials/music-and-scores' },
    formats[:file] => { 'General Materials': 'materials' },
    formats[:archival] => { 'Archives and Special Collections': 'materials/archives-and-special-collections' },
    formats[:journal] => [
      { 'Journals and Newspapers': 'node/1576' }, { 'Articles': 'materials/articles' }
    ],
    formats[:book] => [
      { 'Books': 'materials/books' }, { 'Audiobooks': 'materials/audiobooks' },
      { 'Theses and Dissertations': 'materials/electronic-theses-and-dissertations' }
    ]
  }.with_indifferent_access.freeze

  def render_more_options_links(document)
    link_el_hashes = document.more_options.map { |v| MATERIAL_TYPE_PAGE_LINKS[v] }.flatten
    links = link_el_hashes.map do |h|
      tag.li(
        tag.a(t('catalog.show.find_more_info') + h.keys[0],
          href: "https://libraries.emory.edu/#{h.values[0]}",
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
