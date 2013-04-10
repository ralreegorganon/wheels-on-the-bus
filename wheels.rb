#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'json'

wheels = {:timestamp => Time.new,:routes => [], :stop_schedules => []}
doc = Nokogiri::HTML(open('http://bustracker.muni.org/InfoPoint/noscript.aspx'))
wheels[:routes] = doc.css('.routeNameListEntry').map {|l| {:id => l['routeid'], :name => l.content}}
wheels[:routes].each do |r|
  doc = Nokogiri::XML(open("http://bustracker.muni.org/InfoPoint/map/GetRouteXml.ashx?routeNumber=#{r[:id]}"))
  stops = doc.css('stop').map do |s|
    stop = {:id => s['html'], :name => s['label'], :lat => s['lat'], :lng => s['lng']}
  end
  r[:stops] = stops
  trace_url = doc.css('info').first['trace_kml_url']
  doc = Nokogiri::XML(open(trace_url))
  r[:geometry] = doc.css('coordinates').map do |line|
    segments = line.text.split(' ').map do |p|
      c = p.split(',')
      {:lat => c[1], :lng => c[0]}
    end
  end
  doc = Nokogiri::XML(open("http://bustracker.muni.org/InfoPoint/map/GetVehicleXml.ashx?RouteId=#{r[:id]}"))
  vehicles = doc.css('vehicle').map do |v|
    doc = Nokogiri::HTML(open("http://bustracker.muni.org/InfoPoint/map/GetVehicleHtml.ashx?vehicleid=#{v['name']}"))
    vehicle = {:id => v['name'], :lat => v['lat'], :lng => v['lng'] }
    doc.css('li').each do |l|
      kv = l.text.split(':')
      vehicle[kv.first.gsub(/\s+/,"_").strip.downcase.to_sym] = kv.last.strip
    end
    vehicle
  end
  r[:vehicles] = vehicles
end
wheels[:stop_schedules] = wheels[:routes].map {|r| r[:stops].map {|s| s[:id]}}.flatten.uniq.map do |s|
  doc = Nokogiri::HTML(open("http://bustracker.muni.org/InfoPoint/map/GetStopHtml.ashx?stopid=#{s}"))
  sched = {:stop_id => s}
  sched[:departures] = doc.css('.oddDepartureGroup,.evenDepartureGroup').map do |d|
    td = d.css('td')
    {:route => td[0].text, :destination => td[1].text, :sdt => td[2].text, :edt => td[3].text}
  end
  sched
end
puts JSON.generate(wheels)
