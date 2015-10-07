require 'nokogiri'
require 'open-uri'
require 'json'
require 'cgi'

#Soundcloud API key
apiClientId = '34d6b7ae113a70add0d6eb096e7061f7'

#Soundcloud RSS URL
feed = "http://feeds.soundcloud.com/users/soundcloud:users:48054353/sounds.rss"

puts "\nRetrieving RSS feed...\n"
doc= Nokogiri::HTML(open(feed, 'User-Agent' => 'ruby'))
puts "\nDone.\n"
puts "\nParsing feed items...\n\n"
items=doc.css('item')
if !items.empty?
  items.each do |item|
    #get rss fields
    itemTitle=item.at("title").text
    pubDate=item.at("pubdate").text
    duration = item.at("duration").text
    url = item.at("enclosure")["url"]
    length = item.at("enclosure")["length"]
    
    #Parsing
    #episode number
    epMatch = itemTitle.match(/Ep.(.*):/)
    number = epMatch[1]
    
    #episode title (stripped of podcast name, ep no.)
    title = itemTitle.split(': ', 2).last
    
    #guest
    guestMatch = title.match(/Feat. (.*)\)/)
    if(!guestMatch.nil?)
      #populate guest field
      guest = guestMatch[1]
      #remove guest from title
      title = title.split(" (Feat.").first
    end
    
    #soundcloud id
    guid = item.at("guid").text
    soundcloudId = guid.split('/')[-1]
    
    #Soundcloud API calls
    #track description
    trackApiUrl = 'http://api.soundcloud.com/tracks/' + soundcloudId + '?client_id=' + apiClientId
    jsonTrack = JSON.load(open(trackApiUrl))
    trackDescription = jsonTrack["description"]
    description = trackDescription.split("***").first.strip
    
    #Directory/file path
    if itemTitle.include? "Hmm Interesting Choice"
      podcast = 'hmm-interesting-choice'
    elsif itemTitle.include? "Dessert Island Discs"
      podcast = 'dessert-island-discs'
    elsif itemTitle.include? "Podghast Spooktacular"
      podcast = 'podghast-spooktacular'
    end
    relativeFilePath = '../_episodes/'+ podcast + '/' + number+'.md'
    filePath = File.expand_path(relativeFilePath, __FILE__)
    
    puts "Saving: "+relativeFilePath
    
    #Save file
    out_file = File.new(filePath, "w")
    out_file.puts("---\n")
    out_file.puts("title: #{CGI.escapeHTML(title)}\n")
    if(!guest.nil?)
      out_file.puts("guest: #{guest}\n")
    end
    out_file.puts("number: #{number}\n")
    out_file.puts("description: #{CGI.escapeHTML(description)}\n")
    out_file.puts("link-mp3: #{url}\n")
    out_file.puts("duration: \"#{duration}\"\n")
    out_file.puts("byte-length: #{length}\n")
    out_file.puts("pub-date: #{pubDate}\n")
    out_file.puts("soundcloud-id: #{soundcloudId}\n")
    out_file.puts("---\n")
    out_file.close
  end
end

puts "\nComplete!\n"

