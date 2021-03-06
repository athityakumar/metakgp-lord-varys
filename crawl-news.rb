require 'mechanize'
require 'json'

bot = Mechanize.new
bot.follow_meta_refresh = true 
bot.verify_mode = OpenSSL::SSL::VERIFY_NONE

begin
  news_list = JSON.parse(File.read("news.json"))
  puts "#{news_list.length} news articles already exist."
rescue Exception => e
  puts "Error rescued : #{e.to_s}"
end 

id = bot.get("http://iitkgp.ac.in/").search(".description a")[0]["href"].gsub("shownews.php?newsid=","").to_i

while id > 0 do
  crawl_url = "http://iitkgp.ac.in/shownews.php?newsid="+id.to_s
  page = bot.get(crawl_url).search("td")
  head , desc = page[0].text.strip , page[1].text.strip.gsub("\r","").gsub("\n","").encode("UTF-8", invalid: :replace, undef: :replace).gsub("\t","")

  unless head.empty?
    news = { "Headlines" => head, "Description" => desc }
    news_list.push(news)  
  end
  puts "Scraped news article #"+id.to_s
  id = id - 1
end

puts "#{news_list.length} news articles now."
if File.exist? Dir.pwd+"/news.json"
  File.delete("news.json")
end

File.open("news.json", "a") { |file| file.write(JSON.generate(news_list)) }
