module OmniAuth
  module Strategies
    class Irma
      class Engine < Rails::Engine; end

      include OmniAuth::Strategy

      option :fields, %i[email zipcode over18 gender]
      option :uid_field, :email

      option :irma_server, "http://localhost:8088"
      option :attrs_register, [[["pbdf.pbdf.email.email"]],[["pbdf.gemeente.address.zipcode","pbdf.gemeente.personalData.over18","pbdf.gemeente.personalData.gender"]]]
      option :attrs_login, [[["pbdf.pbdf.email.email"]]]

      LOOKUP = {
        "pbdf.pbdf.email.email" => {:key => :email},
        "pbdf.gemeente.address.zipcode" => {:key => :zipcode},
        "pbdf.gemeente.personalData.over18" => {:key => :over18, :replace => {"Yes" => true, "No" => false}},
        "pbdf.gemeente.personalData.gender" => {:key => :gender, :replace => {"M" => "male", "F" => "female"}},
      }
      option :attrs_lookup, LOOKUP

      def request_phase
        registering = !Rack::Utils.parse_nested_query(request.query_string)["register"].nil?
        disclose = registering ? options[:attrs_register].to_json : options[:attrs_login].to_json
        res = Faraday.post("#{options[:irma_server]}/session",
          "{\"@context\":\"https://irma.app/ld/request/disclosure/v2\",\"disclose\":#{disclose}}", 
          "Content-Type" => "application/json").body
        Rack::Response.new(res, 200, "content-type" => "application/json").finish
      end

      uid do
        sessiontoken = token request
        attrs = raw_info sessiontoken
        attrs[:email]
      end

      info do
        sessiontoken = token request
        attrs = raw_info sessiontoken
        attrs
      end

      def token(request)
        Rack::Utils.parse_nested_query(request.query_string)["sessiontoken"]
      end

      def raw_info(sessiontoken)
        if @raw_info.nil?
          sessionresult = JSON.load(Faraday.get("#{options[:irma_server]}/session/#{sessiontoken}/result").body)

          @raw_info = {}
          lookup = LOOKUP.merge(options[:attrs_lookup])
          puts lookup.to_json
          sessionresult["disclosed"].each do |concon|
            concon.each do |con|
              attribute_id = con["id"]
              opts = lookup[attribute_id]
              raw_info_key = opts[:key]
              raise RuntimeError if raw_info_key.nil?
              val = con["rawvalue"]
              if !opts[:replace].nil? && opts[:replace].key?(val)
                val = opts[:replace][val]
              end
              @raw_info[raw_info_key] = val
            end
          end
        end
        @raw_info
      end
    end
  end
end
