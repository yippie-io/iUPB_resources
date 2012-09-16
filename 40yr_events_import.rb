# encoding: UTF-8
require 'nokogiri'
require 'open-uri'
require 'mongoid'
require 'date'

ENV["MONGOID_ENV"] = "development"
Mongoid.load!("mongoid.yml")

class FortyYearsEvent
  include Mongoid::Document
  field :start_time, type: DateTime
  field :end_time, type: DateTime
  field :name, type: String
  field :description, type: String
  field :location, type: String
  field :link, type: String
end

URLS = ["http://40jahre.uni-paderborn.de/index.php?id=6&tx_ltxunipbevents_list%5Bshow%5D=all&tx_ltxunipbevents_list%5Bcontroller%5D=Event&cHash=0a6d36cb8d7a484424fc3bf4400d2d9d",
	"http://40jahre.uni-paderborn.de/index.php?id=6&tx_ltxunipbevents_list%5Bshow%5D=all&tx_ltxunipbevents_list%5Bcontroller%5D=Event&tx_ltxunipbevents_list%5B%40widget_0%5D%5BcurrentPage%5D=2&cHash=219add486698db994008f4dfa0299f17",
	"http://40jahre.uni-paderborn.de/index.php?id=6&tx_ltxunipbevents_list%5Bshow%5D=all&tx_ltxunipbevents_list%5Bcontroller%5D=Event&tx_ltxunipbevents_list%5B%40widget_0%5D%5BcurrentPage%5D=3&cHash=543f420f87f1cb35db5cebec420ee82c",
	"http://40jahre.uni-paderborn.de/index.php?id=6&tx_ltxunipbevents_list%5Bshow%5D=all&tx_ltxunipbevents_list%5Bcontroller%5D=Event&tx_ltxunipbevents_list%5B%40widget_0%5D%5BcurrentPage%5D=4&cHash=011fff88fca971761a1ef0383aa9020d",
	"http://40jahre.uni-paderborn.de/index.php?id=6&tx_ltxunipbevents_list%5Bshow%5D=all&tx_ltxunipbevents_list%5Bcontroller%5D=Event&tx_ltxunipbevents_list%5B%40widget_0%5D%5BcurrentPage%5D=5&cHash=7c110cf789948b7d89f2f2a5e78027f9", 
	"http://40jahre.uni-paderborn.de/index.php?id=6&tx_ltxunipbevents_list%5Bshow%5D=all&tx_ltxunipbevents_list%5Bcontroller%5D=Event&tx_ltxunipbevents_list%5B%40widget_0%5D%5BcurrentPage%5D=6&cHash=f470c8bbd1d7e58eab87fc528be4c024",
	"http://40jahre.uni-paderborn.de/index.php?id=6&tx_ltxunipbevents_list%5Bshow%5D=all&tx_ltxunipbevents_list%5Bcontroller%5D=Event&tx_ltxunipbevents_list%5B%40widget_0%5D%5BcurrentPage%5D=7&cHash=715c6b00924179d2214dca7cdc9ed3a0"
]

events = []
URLS.each do |url|
doc = Nokogiri::HTML(open(url))

doc.css('a.more').each do |link|
	page = Nokogiri::HTML(open("http://40jahre.uni-paderborn.de/" + link.attr("href")))
  	name = page.css('div.program_detail h3').first.content.strip
  	time_string = page.css("div.program_info p").first.content.strip
  	location_string = page.css("div.program_info p").last.content.strip
  	time_string = time_string.sub("Datum", "").sub("Uhr", "")
  	if time_string.include?("bis")
  		start = DateTime.parse(time_string.split("bis").first.strip)
  		finish = DateTime.parse(time_string.split("bis").last.strip)
  	else
  		start = finish = DateTime.parse(time_string.strip)
  	end
  	location = location_string.sub("hier geht es zum Gebäudeplan", "").sub("Veranstaltungsort", "").strip
  	description = page.css('div.program_detail p.bodytext').first.content.strip
  	e = FortyYearsEvent.new
  	e.name = name
  	e.location = location
  	e.description = description
  	e.link = "http://40jahre.uni-paderborn.de/" + link.attr("href")
  	e.start_time = start
  	e.end_time = finish
  	e.save!
  	events << e
end

end
puts "imported #{events.count} events"