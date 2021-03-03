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
    config.add_show_field 'author_display_ssim', label: 'Author/Creator'
    config.add_show_field 'publication_main_display_ssm', label: 'Publication'
    config.add_show_field 'marc_resource_ssim', label: 'Resource Type'
    config.add_show_field 'title_details_display_tesim', label: 'Title'
    config.add_show_field 'title_addl_tesim', label: 'More Title Info'
    config.add_show_field 'title_varying_tesim', label: 'Variant Titles'
    config.add_show_field 'author', field: 'author_display_ssim', label: 'Author/Creator'
    config.add_show_field 'subject_tsim', label: 'Subjects'
    config.add_show_field 'edition_tsim', label: 'Edition'
    config.add_show_field 'publisher_details_display_ssm', label: 'Publisher'
    config.add_show_field 'pub_date_isi', label: 'Creation Date'
    config.add_show_field 'material_type_display_tesim', label: 'Format'
    config.add_show_field 'note_general_tsim', label: 'Local Note'
    config.add_show_field 'language_tesim', label: 'Language'
    config.add_show_field 'summary_tesim', label: 'Summary'
    config.add_show_field 'isbn_ssim', label: 'Identifier'
    config.add_show_field 'publication_details', field: 'publication_main_display_ssm', label: 'Publication Info'
    config.add_show_field 'format_ssim', label: 'Type'
    config.add_show_field 'lc_callnum_display_ssi', label: 'Call Number'
    config.add_show_field 'id', label: 'MMS ID'

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
      'isbn_ssim', 'id', 'title_display_tesim', 'title_vern_display_tesim', 'title_addl_tesim', 'title_added_entry_tesim',
      'title_series_ssim', 'subtitle_display_tesim', 'subtitle_vern_display_tesim', 'author_display_ssim', 'author_vern_ssim',
      'author_addl_tesim', 'subject_tsim', 'subject_addl_tsim', 'subject_topic_facet_ssim', 'subject_era_ssim',
      'subject_geo_ssim', 'lc_callnum_display_ssi', 'language_tesim'
    ]
    author_fields = ['author_tesim', 'author_display_ssim', 'author_vern_ssim', 'author_si', 'author_addl_tesim']
    title_fields = ['title_tesim', 'title_display_tesim', 'title_vern_display_tesim', 'title_ssort',
                    'title_addl_tesim', 'title_abbr_tesim', 'title_added_entry_tesim', 'title_enhanced_tesim',
                    'title_former_tesim', 'title_graphic_tesim', 'title_host_item_tesim', 'title_key_tesi',
                    'title_series_ssim', 'title_translation_tesim', 'title_varying_tesim']

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field('keyword', label: 'Keyword') do |field|
      field.solr_parameters = {
        qf: keyword_fields.join(' '),
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
