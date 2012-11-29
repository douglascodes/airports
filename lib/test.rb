require '.\lib\gtoxls'
require 'net/http'
require 'rexml/document'
require 'action_view'
include REXML
include ActionView::Helpers::SanitizeHelper



# lat = 39.955929
# lng = -75.157457
# s = "http:\/\/maps.googleapis.com\/maps\/api\/geocode\/xml\?latlng\=#{lat},#{lng}\&sensor\=true"
# search = URI(s)
# results = Net::HTTP.get(search)
# d = Document.new(results)
# x = XPath.first(d, "/GeocodeResponse/result/formatted_address")
# s = strip_tags(x.to_s)
# puts s