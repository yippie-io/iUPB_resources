require 'nokogiri'
require 'open-uri'
require 'pp'

doc = Nokogiri::HTML(open('http://40jahre.uni-paderborn.de/index.php?id=22'))
arr = []
doc.css('ol.facts li').each do |link|
  nr = link.css('strong').first
  arr.push({ :id => nr.content.to_i, :text => link.content.sub(nr, "").strip })
end
pp arr