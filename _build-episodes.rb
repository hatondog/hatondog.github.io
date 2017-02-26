require 'nokogiri'
require 'open-uri'
require 'cgi'

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
    itemDescription=item.at("description").text
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
    
    #track description
    description = itemDescription.split("***").first.strip
    
    #soundcloud id
    guid = item.at("guid").text
    soundcloudId = guid.split('/')[-1]
    
    
    #Directory/file path
    if itemTitle.include? "Hmm Interesting Choice"
      podcast = 'hmm-interesting-choice'
    elsif itemTitle.include? "Dessert Island Discs"
      podcast = 'dessert-island-discs'
    elsif itemTitle.include? "Podghast Spooktacular"
      podcast = 'podghast-spooktacular'
    elsif itemTitle.include? "Verse Chorus Verse"
      podcast = 'verse-chorus-verse'
    elsif itemTitle.include? "Keeping Up With Keeping Up With The Kardashians"
      podcast = 'kuwkuwtk'
    elsif itemTitle.include? "Dash Kapital"
      podcast = 'dash-kapital'
    end
    relativeFilePath = '../_episodes/'+ podcast + '/' + number+'.md'
    filePath = File.expand_path(relativeFilePath, __FILE__)
    slug = title.downcase.strip.gsub('- ', '').gsub(' ', '-').gsub(/[^\w-]/, '')
     if(!guest.nil?)
      slug = slug + '-' + guest.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
    title = CGI.escapeHTML(title)
    
    puts "Saving: "+relativeFilePath
    
    #Save file
    out_file = File.new(filePath, "w")
    out_file.puts("---\n")
    out_file.puts("title: #{title}\n")
    out_file.puts("slug: #{slug}\n")
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

