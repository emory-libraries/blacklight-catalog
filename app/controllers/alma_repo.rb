class AlmaRepo
  class << self
    def req_doc
      '{
 "request_type": "HOLD",
 "holding_id": "%s",
 "pickup_location_type": "LIBRARY",
 "pickup_location_library": "%s",
 "pickup_location_institution": "01GALI_EMORY"
 }'
    end
    def host
      "api-na.hosted.exlibrisgroup.com"
    end

    def general_libraries
       %w/BUS CHEM EMOL EUH GRADY HLTH LAW LSC MARBL MID THEO UNIV/
    end

    def general_library_pickup_options
      %w/HLTH LAW LSC MUSME OXFD THEO UNIV UNIVLOCK/
    end


    def oxford_user_group_ids
      %w/23 24 25 26/
    end

    def is_oxford_user?(group_id)
      oxford_user_group_ids.include?(group_id)
    end

    def is_music_location?(location)
      music_locations.include?(location)
    end

    def music_locations
      %w/DVDL MEDIA MEDIAOSIZE/
    end

    def get_delivery_options(user_group_id, location_id, holding_lib)
      if general_libraries.include?(holding_lib)
        general_library_pickup_options
      elsif holding_lib == "OXFD" 
        is_oxford_user?(user_group_id) ? ["OXFD"] : general_library_pickup_options
      elsif holding_lib == "MUSME"
        if is_music_location?(location_id) && is_oxford_user?(user_group_id)
          ["OXFD"]
        elsif (is_music_location?(location_id) && !is_oxford_user?(user_group_id)) || location_id == "7DEQUIP"
          ["MUSME"]
        else
          general_library_pickup_options
        end
      else
        raise "Invalid delivery option #{holding_lib} #{location_id}, #{user_group_id}"
      end
    end

    def request_options_url(uid, mmsid, apikey)
      "https://#{host}/almaws/v1/bibs/#{mmsid}/request-options?user_id=#{uid}&consider_dlr=false&apikey=#{apikey}"
    end

    def retrieve_holdings_url(mmsid, apikey)
      "https://#{host}/almaws/v1/bibs/#{mmsid}/holdings?apikey=#{apikey}"
    end

    def user_group_url(uid,apikey)
      "https://#{host}/almaws/v1/users/#{uid}?user_id_type=all_unique&view=full&expand=none&apikey=#{apikey}"
    end

    def check_request(uid, mmsid, apikey)

      begin
        d = Nokogiri::XML(RestClient.get(request_options_url(uid, mmsid, apikey)).body)
        d.remove_namespaces!
        req_options = d.xpath("//request_options/request_option/type[text()='HOLD']")
        is_requestable = !req_options.empty?
        holdings_doc = Nokogiri.XML(RestClient.get(retrieve_holdings_url(mmsid, apikey)).body)
        location_id = holdings_doc.xpath('//holdings/holding/location').text
        user_info_doc = Nokogiri.XML(RestClient.get(user_group_url(uid, apikey)).body)
        user_group_id = user_info_doc.xpath("//user/user_group").text
        holding_id = holdings_doc.xpath("//holdings/holding/holding_id").text
        holding_lib = holdings_doc.xpath("//holdings/holding/library").text
        delivery_options = get_delivery_options(user_group_id, location_id, holding_lib)
      [:ok, is_requestable, delivery_options, holding_id, holding_lib]
      rescue RestClient::BadRequest => x
        d = Nokogiri::XML(x.response)
        d.remove_namespaces!
        [:error, d.xpath("//web_service_result/errorList/error/errorMessage").map(&:text).join(", ")]
      end


    end

    def make_request(uid, mmsid, apikey,  holding_id, pickup_location_lib)
      begin
        agent = Mechanize.new
        create_user_request =  "https://#{host}/almaws/v1/users/#{uid}/requests?user_id_type=all_unique&allow_same_request=false&apikey=#{apikey}&mms_id=#{mmsid}"
        res = agent.post(create_user_request, req_doc%[holding_id, pickup_location_lib], "Content-Type"=>'application/json', "Accept"=>'application/json').body
        JSON.pretty_generate(JSON.parse(res))
      rescue Mechanize::ResponseCodeError => x 
       "Error: #{JSON.pretty_generate(JSON.parse(x.page.body))}"
      end
    end
  end
end

if $0 == __FILE__ ; main end
