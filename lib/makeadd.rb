require 'open-uri'
require 'nokogiri'
require 'csv'
require 'spreadsheet'
require 'json'
require 'rubygems'
require 'base64'
require 'hmac'
require 'hmac-sha1'

def urlSafeBase64Decode(base64String)
  return Base64.decode64(base64String.tr('-_','+/'))
end

def urlSafeBase64Encode(raw)
  return Base64.encode64(raw).tr('+/','-_')
end


def signURL(key, url)
  parsedURL = URI.parse(url)
  urlToSign = parsedURL.path + '?' + parsedURL.query

  # Decode the private key
  rawKey = urlSafeBase64Decode(key)

  # create a signature using the private key and the URL
  sha1 = HMAC::SHA1.new(rawKey)
  sha1 << urlToSign
  rawSignature = sha1.digest()

  # encode the signature into base64 for url use form.
  signature =  urlSafeBase64Encode(rawSignature)

  # prepend the server and append the signature.
  signedUrl = parsedURL.scheme+"://"+ parsedURL.host + urlToSign + "&signature=#{signature}"
  return signedUrl
end


class Airport_Reader
	attr_accessor :input, :output, :lines, :a_ports, :book, :sheet, :headers

		# def initialize
		# 	@a_ports = Hash.new
		# 	@output = CSV.new
		# 	read_file
		# 	break_addy
		# end

		def read_xls(file='./data/faa.xls')
			@a_ports = Hash.new
			@book = Spreadsheet.open file
			@sheet = book.worksheet 0
			@headers = @sheet.row 0
			
			@sheet.each 2 do |r|
			 	a = Airport.new()
				a.type = r[0]
				a.code = r[1]
				a.state = r[2]
				a.county = r[3]
				a.city = r[4]
				a.name = r[5]
				a.address = r[6]
				a.lat = r[7]
				a.long = r[8]
				a.elev = r[9]
				a.area = r[10]
				@a_ports.merge!({a.code=>a})
			end
		end

	def find_json(a)
		s = "http://maps.googleapis.com/maps/api/geocode/json\?latlng\=#{a.lat},#{a.long}\&sensor\=true"
		# r = open(URI(s))
		x = Nokogiri::HTML(open(s))
		j = JSON.parse(x)
		jr = j["results"]
		if jr.first 
			frst = jr.first["formatted_address"]
		return frst
		end
		return nil
		# d = Document.new(results)
		# x = XPath.first(d, "/GeocodeResponse/result/formatted_address")
		# s = strip_tags(x.to_s)
		# return s
	end

	def find_address
		@a_ports.each_value { |p|
			p.address = find_json(p)
		}
	end

	def input_address_to_doc
		@sheet.each 2 do |row|
			p = @a_ports[row[1]]
			row[6] = p.address
		end
	end

	def write_xls(file='./data/faa2.xls')
		@book.write(file)	
	end
		# def read_csv(file='./data/airports.csv')
		# 	@a_ports = Hash.new
		# 	CSV.foreach(file) do |row|
		# 		a = Airport.new
		# 		a.code = row[0]
		# 		a.city = row[1]
		# 		a.state = row[2]
		# 		a.extra = row[3]
		# 		a.address = row[4]
		# 		a.lat = row[5]
		# 		a.long = row[6]	  		
		# 		@a_ports.merge!({a.code=>a})
	 #  	end
		# end

		# def read_text_file(file='./data/airports.txt')
		# 	# return unless File.exist?(file)
		# 	@input = IO.readlines(file)
		# 	@input.keep_if { |l|
		# 		l.index(/\(.{3}\)/)
		# 	}
		# 	@input.each { |c| c.chomp! }
			
		# end

		# def digest_text
		# 	read_text_file()
		# 	convert_lines_to_hashes
		# 	write_to_file
		# end

		# def digest_csv_file
		# 	read_csv()
		# 	#search_docs()		
		# 	#write_to_file
		
		# end

		def search_docs(h=@a_ports)
			h.each_value { |a|
				search_airport(a)

			}
		end

		# def break_addy(b)
		# 	p = Airport.new
		# 	a = b.index(',')
		# 	if not a then return end
		# 	p.city = b.slice!(0, a)
		# 	p.state = b.slice!(2,2)
		# 	b.lstrip!
		# 	r = b.index(/\(...\)/)
		# 	p.code = b.slice!(r+1, 3)
		# 	p.extra = trim_extra(b.slice!(0,r))
		# 	while @a_ports.key?(p.code) == true
		# 		p.code << "x" 
		# 	end
		# 	@a_ports.merge!({p.code=>p})
		# 	return p
		# end
		
		# def trim_extra(e)
		# 	e = e.slice!(/[\w]+[\w ]*/)
		# 	if e then e.strip! end
		# 	return e
		# end

		# def convert_lines_to_hashes
		# 	@a_ports = Hash.new
		# 	@input.each { |l|
		# 		break_addy(l)
		# 	}
		# end

		# def write_to_file(file='./data/airports.csv')
		# 	CSV.open(file, "wb") do |csv|
  # 			@a_ports.each_value { |p| 
		# 			csv << [p.code, p.city, p.state, p.extra, p.address, p.lat, p.long]
  # 			}
  # 		end
		# end
end

class Airport
	attr_accessor :type, :code, :state, :county, :city, :name, :address, :lat, :long, :elev, :area

	def to_s
		if @extra
			@code + " " + @extra + " airport in " + @city + ", " + @state
		else
			@code + " airport in " + @city + ", " + @state 
		end
	end

end
