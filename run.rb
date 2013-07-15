require 'kayako_client'
require 'psych'

configFileName = 'D:\Documents\RubyMine\KayakoNewsToWiki\config.yml'

configFile = begin
  Psych.load_file(configFileName)
rescue Psych::SyntaxError => ex
  puts "Could not parse #{ex.file}: #{ex.message}"
  exit(1)
end

KayakoClient::Base.configure do |config|
  config.api_url    = configFile[:URL]
  config.api_key    = configFile[:KEY]
  config.secret_key = configFile[:SECRET]
end

news = KayakoClient::NewsItem.all()

if news.count > 0
  news.each do |news|
    puts "#{news.id}. #{news.subject} :: #{news.contents}"
  end
else
    puts "Notes missing."
end

stream = Psych::Stream.new(File.open(configFileName, 'w'))
stream.start
stream.push({:LastProcessedNewsItem => configFile[:LastProcessedNewsItem],
             :LastProcessingTime => DateTime.now(),
             :URL => configFile[:URL],
             :KEY => configFile[:KEY],
             :SECRET => configFile[:SECRET]})
stream.finish
