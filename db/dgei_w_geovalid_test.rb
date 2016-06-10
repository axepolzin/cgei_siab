require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'csv'

pin_array = []
CSV.foreach("hyde_park_pins_2014_togo.csv") {|row| pin_array << row[0]}
#gets pins from csv

puts "This many rows: #{pin_array.count}"
pin_array.compact!
puts "This many rows after compact: #{pin_array.count}"
pin_array.reverse.keep_if{|a| a.start_with?("2023")}
#limits to Hyde Park; SIAB block 2023424
#later: make this filter user input


puts "This many in our block: #{pin_array.count}"



CSV.open("hyde_park_parsed_neighborhoodmore.csv", "w+") do |csv|
  csv << ["pin","lat", "long", "address", "address_number", "address_rose", "address_street", "address_suffix", "address_formatted", "city", "township", "zip", "property_class", "name", "tax_address", "tax_street_number", "tax_street_rose", "tax_street_name", "tax_street_suffix", "tax_city", "tax_state", "tax_zip", "formatted_tax_address", "tax_lat", "tax_long"]
end
#"number", "rose", "street", "suffix","name_first", "name_last","tax_number", "tax_rose", "tax_street", "tax_suffix"

#test sample: pin_array = ["20234240560000","20234240230000","20234240510000","20234240500000"]



pin_array.each do |pin|
  puts "PIN: #{pin}"
  url = "http://www.cookcountypropertyinfo.com/Pages/PIN-Results.aspx?PIN=#{pin}"
  agent = Mechanize.new
  page = agent.get(url)

  #property info
  #pin_formatted = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyPIN').text
  @address = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyAddress').text



  @city = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyCity').text
  @township = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyTownship').text
  @zip = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyZip').text
  @property_class = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyClass').text
  @property_class_desc = page.css('span#ctl00_PlaceHolderMain_ctl00_mspPropertyClassDescription').text
  #above field is in popup window


  #property tax info
  @name = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyMailingName').text
  # how to parse out companies, trusts etc? if last = llc, etc then ??
  @tax_address = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyMailingAddress').text
  @tax_csz = page.css('span#ctl00_PlaceHolderMain_ctl00_propertyMailingCityStateZip').text

  if @tax_csz != ""
    @tax_city = @tax_csz.split[0..-3].join(" ").gsub(/[[:punct:]]/, '')
    @tax_state = @tax_csz.split[-2]
    @tax_zip = @tax_csz.split[-1]
  end

  #validates and parses address using google maps
  puts @address

  @street_address = @address

  @apt_test = @street_address[-1]

  if @apt_test == "0" then
    @apt_test = "1"
  end

  @apt_test = @apt_test.to_i

  if @apt_test >= 1
    then
    @street_address = @street_address.split[0..-2].join(" ")
    @apt = @street_address.split[-2]
  else
    @apt = ""
  end

  unless @address == "" || @address == nil
    @url_safe_street_address = URI.encode(@street_address)
    @url_safe_city = URI.encode(@city)

    puts "Address: #{@street_address}"
    url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{@url_safe_street_address}"
    page = agent.get(url)

    require 'json'
    parsed_data = JSON.parse(open(url).read)

    @status = parsed_data["status"]
    unless @status != "OK"
      @latitude = parsed_data["results"][0]["geometry"]["location"]["lat"]
      @longitude = parsed_data["results"][0]["geometry"]["location"]["lng"]
      @type = parsed_data["results"][0]["address_components"][0]["types"][0]
      @formatted_address = parsed_data["results"][0]["formatted_address"]

      if @type == "street_number" then
        @street_number = parsed_data["results"][0]["address_components"][0]["long_name"]
        @street = parsed_data["results"][0]["address_components"][1]["short_name"]
        @street_name = @street
        @street_rose = @street.split[0]
        @street_suffix = @street.split[-1]

        if @street_suffix ==  "Blvd" || @street_suffix ==  "Ct" ||@street_suffix ==   "Dr" ||@street_suffix ==   "Ln"|| @street_suffix ==  "Pkwy" || @street_suffix ==  "Pl" ||@street_suffix ==   "St" ||@street_suffix ==   "Ave"
          @street_suffix = @street.split[-1]
          @street_name = @street.split[0..-2].join(" ")
        else
          @street_suffix = ""
        end

        #@street_name = @street.split
        @street_rose = @street_name[0]

        if @street_rose == "S" || @street_rose == "N" || @street_rose == "W" || @street_rose == "E" then
          @street_rose = @street.split[0]
          @street_name = @street_name.split[1..-1].join(" ")
        else
          @street_rose = ""
        end

      elsif @type == "subpremise" then
        @street_name = parsed_data["results"][0]["address_components"][2]["long_name"]
      end


      #validates and parses tax address using google maps
      #  @tax_address = tax_address
      puts @tax_address

      if @tax_address == "" then
        @tax_street_number = ""
        @tax_street_rose = ""
        @tax_street_name = ""
        @tax_street_suffix = ""
        @formatted_tax_address = ""
        @tax_city = ""
        @tax_state = ""
        @tax_zip = ""
        @tax_lat = ""
        @tax_long = ""
        puts "No tax address to validate"
      elsif @tax_address.gsub(/\s+/, "").gsub(/[[:punct:]]/, '')[0..4] == ("POBOX")
        @tax_street_number = ""
        @tax_street_rose = ""
        @tax_street_name = ""
        @tax_street_suffix = ""
        @formatted_tax_address = ""
        @tax_lat= ""
        @tax_long = ""

      elsif @tax_csz == "" then
        @tax_city = ""
        @tax_state = ""
        @tax_zip = ""
        @tax_lat = ""
        @tax_long = ""
      else
        @apt_tax_test = @tax_address.split[-1]

        if @apt_tax_test.length < 2
          @apt_test_msg = "true"
          @tax_address= @tax_address.split[0..-2].join(" ")
        elsif
          /\d/.match( @apt_tax_test ) then
          @apt_tax_test_msg = "true"
          @tax_address= @tax_address.split[0..-2].join(" ")
        else
          @apt_test_msg = "false"
          @apt = ""
        end

        puts "Apt Test: #{@apt_test_msg}"

        @url_safe_tax_address = URI.encode(@tax_address)
        @url_safe_tax_csz = URI.encode(@tax_csz)
        puts "Associated Tax Address: #{@url_safe_tax_address}%#{@url_safe_tax_csz}"
        url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{@url_safe_tax_address}%#{@url_safe_tax_csz}"
        page = agent.get(url)

        require 'json'
        parsed_data = JSON.parse(open(url).read)


        @tax_status  = parsed_data["status"]
        unless @tax_status != "OK"

          @tax_lat = parsed_data["results"][0]["geometry"]["location"]["lat"]
          @tax_long= parsed_data["results"][0]["geometry"]["location"]["lng"]
          #    @type = parsed_data["results"][0]["address_components"][0]["types"][0]
          @formatted_tax_address = parsed_data["results"][0]["formatted_address"]

          #    if @type == "street_number" then
          @tax_street_number = parsed_data["results"][0]["address_components"][0]["long_name"]
          @tax_street = parsed_data["results"][0]["address_components"][1]["short_name"]
          @tax_street_name = @tax_street
          @tax_street_rose = @tax_street.split[0]
          @tax_street_suffix = @tax_street.split[-1]


          if @tax_street_suffix ==  "Blvd" || @tax_street_suffix ==  "Ct" ||@tax_street_suffix ==   "Dr" ||@tax_street_suffix ==   "Ln"|| @tax_street_suffix ==  "Pkwy" || @tax_street_suffix ==  "Pl" ||@tax_street_suffix ==   "St" ||@tax_street_suffix ==   "Ave"
            @tax_street_suffix = @tax_street.split[-1]
            @tax_street_name = @tax_street.split[0..-2].join(" ")
          else
            @tax_street_suffix = ""
          end

          #@street_name = @street.split
          @tax_street_rose = @tax_street_name.split[0]

          if @tax_street_rose == "S" || @tax_street_rose == "N" || @tax_street_rose == "W" || @tax_street_rose == "E" then
            @tax_street_rose = @tax_street.split[0]
            @tax_street_name = @tax_street_name.split[1..-1].join(" ")
          else
            @tax_street_rose = ""
          end
        end
      end
    end
  end
    CSV.open("hyde_park_parsed_neighborhoodmore.csv", "a+") do |csv|
      csv << [pin, @latitude, @longitude, @address, @street_number, @street_rose, @street_name, @street_suffix, @formatted_address, @city, @township, @zip, @property_class, @name, @tax_address, @tax_street_number, @tax_street_rose, @tax_street_name, @tax_street_suffix, @tax_city, @tax_state, @tax_zip, @formatted_tax_address, @tax_lat, @tax_long]
    end
    #number, rose, street, suffix, name_first, name_last,tax_number, tax_rose, tax_street, tax_suffix
    sleep 1

  @address = ""
  @latitude=""
  @longitude=""
  @street_number=""
  @street_rose=""
  @street_name=""
  @street_suffix=""
  @formatted_address=""
  @city=""
  @township=""
  @zip=""
  @property_class=""
  @tax_address = ""
  @name=""
  @tax_street_number = ""
  @tax_street_rose = ""
  @tax_street_name = ""
  @tax_street_suffix = ""
  @formatted_tax_address = ""
  @tax_city = ""
  @tax_state = ""
  @tax_zip = ""
  @tax_lat = ""
  @tax_long = ""


end





#The PIN is a 14-digit number composed of a 10-digit base that is modified for condominiums and leaseholds by adding a four-digit unit suffix. The basic PIN structure is:
#AA-SS-BBB-PPP-UUUU
#AA is the AREA number (sequential township)
#SS is the SUBAREA number (section)
#BBB is the BLOCK number
#PPP is the PARCEL number
#UUUU is the UNIT number for condominiums and leaseholds (zeros in this portion of the PIN indicate non-condo and non-leasehold PINs)
#http://www.cookcountyclerk.com/tsd/maps/pages/aboutpins.aspx
