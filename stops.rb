#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'json'
require 'set'

doc = Nokogiri::HTML(open('http://bustracker.muni.org/InfoPoint/noscript.aspx'))
stops = Set.new 
routes = doc.css('.routeNameListEntry').map {|l| {:id => l['routeid'], :name => l.content}}
routes.each do |r|
  doc = Nokogiri::XML(open("http://bustracker.muni.org/InfoPoint/map/GetRouteXml.ashx?routeNumber=#{r[:id]}"))
  doc.css('stop').each do |s|
    stops.add({:id => s['html'], :name => s['label'], :lat => s['lat'], :lng => s['lng']})
  end
end
puts JSON.generate(stops.to_a.sort{|x,y| x[:id] <=> y[:id]})
