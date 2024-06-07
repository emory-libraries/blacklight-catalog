# frozen_string_literal: true
Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :cookie,
    name: 'Cookie',
    description: 'Save feature setting value in a browser cookie. Applies to current user only.'

  strategy :active_record,
    name: 'Database',
    description: 'Save feature setting value in the database. Applies to all users.'

  strategy :default

  feature :enable_requesting_using_api,
    default: false,
    description: "Enable requesting using the ALMA API"

  feature :open_access_facet_by_default,
          default: false,
          description: "Open Access facet by default on the homepage"
end
