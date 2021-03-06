namespace :import do
  desc "Import stops from LAD and LET"
  task stops: :environment do
    stops = {}

    [:LET, :LAD].each do |api|
        url = "http://82.207.107.126:13541/SimpleRIDE/#{api.to_s}/SM.WebApi/api/stops"
        raw_data = %x(curl --silent "#{url}" -H "Accept: application/xml")

        n = Nokogiri::XML(raw_data)
        JSON.parse(n.remove_namespaces!.xpath('//string').text).each do |item|
          item = item.with_indifferent_access

          stops[item[:Code]] = item
        end
    end

    mapping = {code: :Code, name: :Name, longitude: :X, latitude: :Y}

    stops.values.each do |item|
      stop = Stop.find_or_create_by(external_id: item[:Id])
      stop.update Hash[mapping.map{|model_key, json_key| [model_key, item[json_key]] }]
      p stop

      stop.save
    end
  end

end
