# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightRangeLimit::ControllerOverride
  include Blacklight::Catalog
  include Blacklight::Marc::Catalog

  configure_blacklight do |config|
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
    config.index.title_field = 'title_main_display_tesim'
    # config.index.display_type_field = 'format'
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    # config.show.title_field = 'title_tsim'
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'

    # solr fields that will be used for homepage facets
    # When users venture away from the homepage, the full list of facets will
    # be available to them. Any field listed below will appear on the homepage facets.
    config.homepage_facet_fields = ['marc_resource_ssim', 'library_ssim', 'format_ssim', 'language_ssim', 'pub_date_isi']
    config.truncate_field_values = [
      'table_of_contents_tesim', 'summary_tesim', 'note_publication_tesim', 'note_publication_dates_tesim',
      'note_language_tesim', 'note_accessibility_tesim', 'material_type_display_tesim', 'note_technical_tesim',
      'note_access_restriction_tesim', 'note_use_tesim', 'note_general_tsim',
      'note_local_tesim', 'note_participant_tesim', 'url_suppl_ssm'
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

    config.add_facet_field 'marc_resource_ssim', label: 'Access', limit: 5
    config.add_facet_field 'library_ssim', label: 'Library', limit: 25
    config.add_facet_field 'format_ssim', label: 'Resource Type', limit: 25
    config.add_facet_field 'language_ssim', label: 'Language', limit: 5
    config.add_facet_field 'pub_date_isi', label: 'Publication/Creation Date', range: true
    config.add_facet_field 'author_ssim', label: 'Author/Creator', limit: 5
    config.add_facet_field 'subject_ssim', label: 'Subject', limit: 5
    config.add_facet_field 'collection_ssim', label: 'Collection', limit: 5
    config.add_facet_field 'lc_1letter_ssim', label: 'LC Classification', limit: 5
    config.add_facet_field 'subject_geo_ssim', label: 'Region', limit: 5
    config.add_facet_field 'subject_era_ssim', label: 'Era', limit: 5
    config.add_facet_field 'genre_ssim', label: 'Genre', limit: 5

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'author_display_ssim', label: 'Author/Creator'
    config.add_index_field 'format_ssim', label: 'Resource Type'
    config.add_index_field 'marc_resource_ssim', label: 'Access'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    #   Brief Summary Section
    config.add_show_field 'author_display_ssim', label: 'Author/Creator', helper_method: :combine_author_vern
    config.add_show_field('publication_main_display_ssim',
      label: 'Publication/Creation Information',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'format_ssim', label: 'Type', helper_method: :multiple_values_new_line
    config.add_show_field 'edition_tsim', label: 'Edition', helper_method: :multiple_values_new_line
    #   Where to find it section
    config.add_show_field 'url_fulltext_ssm', label: 'Full Text Access', helper_method: :multiple_values_new_line
    #   Additional/Related Title Information Section
    config.add_show_field 'title_addl_tesim', label: 'Full Title', helper_method: :multiple_values_new_line
    config.add_show_field 'title_uniform_ssim', label: 'Uniform Title', helper_method: :multilined_links_to_facet
    config.add_show_field 'title_former_ssim', label: 'Former Titles', helper_method: :multilined_links_to_facet
    config.add_show_field 'title_later_ssim', label: 'Later Titles', helper_method: :multilined_links_to_facet
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
    config.add_show_field('other_standard_ids_ssim',
      label: 'Other Identifiers',
      helper_method: :multiple_values_new_line)
    config.add_show_field 'publisher_number_ssim', label: 'Publisher Number', helper_method: :multiple_values_new_line

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

    author_fields = [
      'author_tesim', 'author_display_ssim', 'author_vern_ssim', 'author_si', 'author_addl_tesim'
    ]
    title_fields = [
      'title_tesim', 'title_display_tesim', 'title_vern_display_tesim', 'title_ssort',
      'title_addl_tesim', 'title_abbr_tesim', 'title_added_entry_tesim', 'title_enhanced_tesim',
      'title_former_tesim', 'title_graphic_tesim', 'title_host_item_tesim', 'title_key_tesi',
      'title_series_ssim', 'title_translation_tesim', 'title_varying_tesim'
    ]

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field('keyword', label: 'Keyword') do |field|
      field.solr_parameters = {
        qf: 'text_tesi id',
        pf: ''
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title', label: 'Title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        'spellcheck.dictionary': 'title',
        qf: title_fields.join(' '),
        pf: ''
      }
    end

    config.add_search_field('author', label: 'Author/Creator') do |field|
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
      field.solr_parameters = {
        qf: 'subject_tsim',
        pf: ''
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_isi desc, title_si asc', label: 'relevance'
    config.add_sort_field 'pub_date_isi desc, title_si asc', label: 'year'
    config.add_sort_field 'author_si asc, title_si asc', label: 'author'
    config.add_sort_field 'title_si asc, pub_date_isi desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrcongig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end
end
