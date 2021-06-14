# frozen_string_literal: true

desc "Update Library Location configuration from Alma API"
task location_update: [:environment] do
  alma_config_key = ENV.fetch('ALMA_CONFIG_KEY')
  api_url = ENV['ALMA_API_URL'] || "https://api-na.hosted.exlibrisgroup.com"
  config_path = File.join('config', 'translation_maps', 'library_location_map.yaml')
  libraries = YAML.load(File.read(config_path))

  libraries.map.with_index do |library, index|
    url = "#{api_url}/almaws/v1/conf/libraries/#{library[:code]}/locations?apikey=#{alma_config_key}"
    response = RestClient.get url, { accept: :json }
    body = JSON.parse(response.body)
    next unless body["location"]
    locations = body["location"].map do |location|
      { code: location["code"], label: location["external_name"]}
    end
    libraries[index][:locations] = locations
  end
  File.open(config_path, "w") { |file| file.write(libraries.to_yaml) }
end
