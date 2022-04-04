# frozen_string_literal: true
require Rails.root.join("lib", "blacklight", "marc", "custom_catalog.rb")

class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include BlacklightRangeLimit::ControllerOverride
  include Blacklight::Catalog
  include Blacklight::Marc::CustomCatalog

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'edismax'
    config.advanced_search[:form_solr_parameters] ||= {
      'facet.field' => [
        "title_main_first_char_ssim", "marc_resource_ssim", "library_ssim", "format_ssim", "language_ssim"
      ],
      "f.title_main_first_char_ssim.facet.limit" => -1,
      "f.marc_resource_ssim.facet.limit" => -1,
      "f.library_ssim.facet.limit" => -1,
      "f.format_ssim.facet.limit" => -1,
      "f.language_ssim.facet.limit" => -1,
      "f.collection_ssim.facet.limit" => 0
    }
    config.advanced_search[:form_facet_partial] ||= 'advanced_search_facets_as_select'

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      rows: 10
    }

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'
    # config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'title_main_display_ssim'
    # config.index.display_type_field = 'format'
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:citation)
    config.add_show_tools_partial(:export_as_ris, partial: 'export_as_ris')
    config.add_show_tools_partial(:print, partial: 'print')
    config.add_show_tools_partial(:direct_link, partial: 'direct_link')
    config.add_show_tools_partial(:search_tips, partial: 'search_tips')
    config.add_show_tools_partial(:ask_librarian, partial: 'ask_librarian')
    config.add_show_tools_partial(:report_problem, partial: 'report_problem')
    config.add_show_tools_partial(:harmful_language, partial: 'harmful_language')
    config.add_show_tools_partial(:librarian_view, label: 'Staff View', if: :render_librarian_view_control?, define_method: false)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    # config.show.title_field = 'title_tsim'
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be used for homepage facets
    # When users venture away from the homepage, the full list of facets will
    # be available to them. Any field listed below will appear on the homepage facets.
    config.homepage_facet_fields = ['marc_resource_ssim', 'library_ssim', 'format_ssim', 'language_ssim']
    config.suppressed_facet_fields = ['title_main_first_char_ssim', 'author_display_ssim']
    config.truncate_field_values = [
      'table_of_contents_tesim', 'summary_tesim', 'note_publication_tesim', 'note_publication_dates_tesim',
      'note_language_tesim', 'note_accessibility_tesim', 'note_production_tesim', 'material_type_display_tesim',
      'note_technical_tesim', 'note_access_restriction_tesim', 'note_use_tesim', 'note_general_tsim',
      'note_local_tesim', 'note_participant_tesim', 'url_suppl_ssm', 'note_time_place_event_tesim',
      'note_arrangement_tesim', 'note_addl_form_tesim', 'note_historical_tesim', 'note_reproduction_tesim',
      'note_location_originals_tesim', 'note_custodial_tesim', 'note_copy_identification_tesim',
      'note_binding_tesim', 'note_citation_tesim', 'note_related_collections_tesim'
    ]

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'title_main_first_char_ssim', label: 'Title Starts With', limit: 5
    config.add_facet_field 'marc_resource_ssim', label: 'Access', limit: 5
    config.add_facet_field 'library_ssim', label: 'Library', limit: 25
    config.add_facet_field 'format_ssim', label: 'Resource Type', limit: 25
    config.add_facet_field 'language_ssim', label: 'Language', limit: 5, index_range: true
    config.add_facet_field 'pub_date_isim', label: 'Publication/Creation Date', range: true
    config.add_facet_field 'author_ssim', label: 'Author/Creator', limit: 5, index_range: true
    config.add_facet_field 'subject_ssim', label: 'Subject', limit: 5, index_range: true
    config.add_facet_field 'collection_ssim', label: 'Collection', limit: 5, index_range: true
    config.add_facet_field 'lc_1letter_ssim', label: 'LC Classification', limit: 5
    config.add_facet_field 'subject_geo_ssim', label: 'Region', limit: 5, index_range: true
    config.add_facet_field 'subject_era_ssim', label: 'Era', limit: 5, index_range: [*(0..2), *('A'..'Z')]
    config.add_facet_field 'genre_ssim', label: 'Genre', limit: 5, index_range: true
    config.add_facet_field 'author_display_ssim', label: 'Author', limit: 5

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'author_display_ssim', label: 'Author/Creator', helper_method: :combine_author_vern
    config.add_index_field('publication_main_display_ssim',
      label: 'Publication/Creation',
      helper_method: :multiple_values_new_line)
    config.add_index_field 'format_ssim', label: 'Resource Type'
    config.add_index_field 'edition_tsim', label: 'Edition', helper_method: :multiple_values_new_line
    config.add_index_field 'bound_with_display_ssim', label: 'Is Part Of', helper_method: :display_bound_with

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    #   Brief Summary Section
    config.add_show_field 'author_display_ssim', label: 'Author/Creator', helper_method: :combine_author_vern
    config.add_show_field('publication_main_display_ssim',
      label: 'Publication/Creation',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'format_ssim', label: 'Resource Type', helper_method: :multiple_values_new_line
    config.add_show_field 'edition_tsim', label: 'Edition', helper_method: :multiple_values_new_line
    config.add_show_field 'bound_with_display_ssim', label: 'Is Part Of', helper_method: :display_bound_with
    #   Where to find it section
    config.add_show_field 'url_fulltext_ssm', label: 'Full Text Access', helper_method: :multiple_values_new_line
    #   Additional/Related Title Information Section
    config.add_show_field 'title_addl_tesim', label: 'Full Title', helper_method: :multiple_values_new_line
    config.add_show_field 'title_uniform_ssim', label: 'Uniform Title', helper_method: :multilined_links_to_facet
    config.add_show_field 'title_former_ssim', label: 'Former Titles', helper_method: :multilined_links_to_title_search
    config.add_show_field 'title_later_ssim', label: 'Later Titles', helper_method: :multilined_links_to_title_search
    config.add_show_field 'title_series_ssim', label: 'Series Titles', helper_method: :multiple_values_new_line
    config.add_show_field 'emory_collection_tesim', label: 'Collection', helper_method: :multiple_values_new_line
    config.add_show_field('title_added_entry_tesim',
      label: 'Related/Included Titles',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'title_varying_tesim', label: 'Variant Titles', helper_method: :multiple_values_new_line
    config.add_show_field 'title_abbr_tesim', label: 'Abbreviated Titles', helper_method: :multiple_values_new_line
    config.add_show_field('title_translation_tesim',
      label: 'Translated Titles',
      helper_method: :multiple_values_new_line)
    #   Related Names Section
    config.add_show_field('author_addl_display_tesim',
      label: 'Additional Author/Creators',
      helper_method: :author_additional_format)
    #   Subjects/Genre Section
    config.add_show_field 'genre_ssim', label: 'Genre', helper_method: :multilined_links_to_facet
    config.add_show_field 'subject_display_ssim', label: 'Subjects', helper_method: :multilined_links_to_facet
    #   Description/Summary Section
    config.add_show_field 'finding_aid_url_ssim', label: 'Finding Aid', helper_method: :generic_solr_value_to_url
    config.add_show_field('table_of_contents_tesim',
      label: 'Table of Contents',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'summary_tesim', label: 'Summary', helper_method: :multiple_values_new_line
    config.add_show_field 'note_publication_tesim', label: 'Publication Note', helper_method: :multiple_values_new_line
    config.add_show_field('note_publication_dates_tesim',
      label: 'Publication Dates',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'holdings_note_tesim', label: 'Holdings Note', helper_method: :multiple_values_new_line
    config.add_show_field 'language_ssim', label: 'Language', helper_method: :multilined_links_to_facet
    config.add_show_field 'note_language_tesim', label: 'Language Note', helper_method: :multiple_values_new_line
    config.add_show_field('note_accessibility_tesim',
      label: 'Accessibility Note',
      helper_method: :multiple_values_new_line)
    config.add_show_field('material_type_display_tesim',
      label: 'Physical Type/Description',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'note_technical_tesim', label: 'Technical Note', helper_method: :multiple_values_new_line
    config.add_show_field('note_access_restriction_tesim',
      label: 'Restrictions on Access',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'note_use_tesim', label: 'Use and Reproduction'
    config.add_show_field 'note_general_tsim', label: 'General Note', helper_method: :multiple_values_new_line
    config.add_show_field 'note_local_tesim', label: 'Local Note', helper_method: :multiple_values_new_line
    config.add_show_field('note_participant_tesim',
      label: 'Participant/Performer Note',
      helper_method: :multiple_values_new_line)
    config.add_show_field('note_production_tesim',
      label: 'Creation/Production Credits Note',
      helper_method: :multiple_values_new_line)
    config.add_show_field('note_time_place_event_tesim',
      label: 'Date/Time and Place of an Event',
      helper_method: :multiple_values_new_line)
    config.add_show_field('note_arrangement_tesim',
      label: 'Organization and Arrangement',
      helper_method: :multiple_values_new_line)
    config.add_show_field('note_addl_form_tesim',
      label: 'Additional Physical Form',
      helper_method: :multiple_values_new_line)
    config.add_show_field('note_historical_tesim',
      label: 'Biographical/Historical Note',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'note_reproduction_tesim', label: 'Reproduction Note', helper_method: :multiple_values_new_line
    config.add_show_field('note_location_originals_tesim',
      label: 'Location of Originals',
      helper_method: :multiple_values_new_line)
    config.add_show_field('note_custodial_tesim',
      label: 'Ownership and Custodial History',
      helper_method: :multiple_values_new_line)
    config.add_show_field('note_copy_identification_tesim',
      label: 'Copy and Version Identification',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'note_binding_tesim', label: 'Binding Note', helper_method: :multiple_values_new_line
    config.add_show_field 'note_citation_tesim', label: 'Citation/Reference Note', helper_method: :multiple_values_new_line
    config.add_show_field('note_related_collections_tesim',
      label: 'Related Collections',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'url_suppl_ssim', label: 'Related Resources Link', helper_method: :generic_solr_value_to_url
    #   Additional Identifiers Section
    config.add_show_field 'id', label: 'Catalog ID (MMSID)'
    config.add_show_field 'isbn_ssim', label: 'ISBN', helper_method: :multiple_values_new_line
    config.add_show_field 'issn_ssim', label: 'ISSN', helper_method: :multiple_values_new_line
    config.add_show_field 'oclc_ssim', label: 'OCLC Number', helper_method: :multiple_values_new_line
    config.add_show_field('other_standard_ids_tesim',
      label: 'Other Identifiers',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'publisher_number_tesim', label: 'Publisher Number', helper_method: :multiple_values_new_line

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    keyword_fields = [
      'title_precise_tesim^100', 'author_tesim^50', 'author_addl_display_tesim^50',
      'subject_tesim^10', 'text_tesi', 'id', 'local_call_number_tesim', 'other_standard_ids_tesim', 'isbn_t', 'issn_t', 'lc_callnum_t'
    ]
    author_fields = [
      'author_tesim', 'author_vern_tesim', 'author_ssort', 'author_addl_display_tesim',
      'note_participant_tesim', 'note_production_tesim'
    ]
    title_fields = [
      'title_tesim', 'title_vern_display_tesim', 'title_addl_tesim', 'title_abbr_tesim',
      'title_added_entry_tesim', 'title_enhanced_tesim', 'title_former_tesim',
      'title_host_item_tesim', 'title_key_tesim', 'title_translation_tesim', 'title_varying_tesim',
      'title_later_tesim', 'title_series_tesim', 'title_precise_tesim^5'
    ]
    title_advanced_fields = [
      'title_addl_tesim', 'title_added_entry_tesim', 'title_abbr_tesim', 'title_former_tesim',
      'title_later_tesim', 'title_host_item_tesim', 'title_translation_tesim', 'title_varying_tesim'
    ]
    author_advanced_fields = [
      'author_addl_display_tesim', 'author_tesim'
    ]
    subject_advanced_fields = [
      'subject_tesim', 'subject_display_ssim'
    ]
    identifier_advanced_fields = [
      'isbn_ssim', 'issn_ssim', 'isbn_t', 'issn_t', 'oclc_ssim', 'other_standard_ids_tesim', 'lccn_ssim', 'id',
      'publisher_number_tesim'
    ]

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field('keyword', label: 'Keyword') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: keyword_fields.join(' '),
        pf: ''
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title', label: 'Title') do |field|
      field.include_in_advanced_search = false
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        'spellcheck.dictionary': 'title',
        qf: title_fields.join(' '),
        pf: ''
      }
    end

    config.add_search_field('author', label: 'Author/Creator') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        'spellcheck.dictionary': 'author',
        qf: author_fields.join(' '),
        pf: ''
      }
    end

    # Field subject_tesim combines MARC tags for Personal Name, Corporate Name, Meeting Name,
    # Uniform Title, Named Event, Chronological Term, Topical Term, Geographic Name,
    # Uncontrolled, Faceted Topical Terms, and Genre/Form into an array.
    config.add_search_field('subject', label: 'Subjects') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'subject_tesim',
        pf: ''
      }
    end

    config.add_search_field('all_fields_advanced', label: 'All Fields') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: 'text_tesi',
        pf: ''
      }
    end

    config.add_search_field('title_advanced', label: 'Title') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: title_advanced_fields.join(' '),
        pf: ''
      }
    end

    config.add_search_field('title_wildcard_advanced', label: 'Main Title (Wildcard Search)') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: 'title_main_display_ssim',
        pf: ''
      }
    end

    config.add_search_field('title_precise', label: 'Precise Title', type: 'hidden') do |field|
      field.include_in_simple_select = false
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'title_precise_tesim',
        pf: ''
      }
    end

    config.add_search_field('author_advanced', label: 'Author/Creator') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: author_advanced_fields.join(' '),
        pf: ''
      }
    end

    config.add_search_field('subject_advanced', label: 'Subject') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: subject_advanced_fields.join(' '),
        pf: ''
      }
    end

    config.add_search_field('title_series_advanced', label: 'Series Title') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: 'title_series_tesim',
        pf: ''
      }
    end

    config.add_search_field('publisher_advanced', label: 'Publisher') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: 'published_tesim',
        pf: ''
      }
    end

    config.add_search_field('identifier_advanced', label: 'Identifiers (ISBN, ISSN, DOI, Other)') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: identifier_advanced_fields.join(' '),
        pf: ''
      }
    end

    config.add_search_field('call_number_advanced', label: 'Local Call Number') do |field|
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: ['local_call_number_tesim', 'lc_callnum_t'].join(' '),
        pf: ''
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_isim desc, title_si asc', label: 'Relevance'
    config.add_sort_field 'pub_date_isim asc, title_ssort asc', label: 'Year (oldest)'
    config.add_sort_field 'pub_date_isim desc, title_ssort asc', label: 'Year (newest)'
    config.add_sort_field 'author_ssort asc, title_ssort asc', label: 'Author (A-Z)'
    config.add_sort_field 'author_ssort desc, title_ssort asc', label: 'Author (Z-A)'
    config.add_sort_field 'title_ssort asc, pub_date_isim desc', label: 'Title (A-Z)'
    config.add_sort_field 'title_ssort desc, pub_date_isim desc', label: 'Title (Z-A)'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = -1

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrcongig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end
end
