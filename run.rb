require 'kayako_client'
require 'psych'

configFileName = 'config.yml'

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

news.each_index do |i|
  if news[i].date_line < configFile[:LastProcessingTime]
    puts "Already processed #{news[i].subject}."
    next
  else
    puts "Processeing #{news[i].subject}."
  end
end

stream = Psych::Stream.new(File.open(configFileName, 'w'))
stream.start
stream.push({:LastProcessingTime => Time.now,
             :URL => configFile[:URL],
             :KEY => configFile[:KEY],
             :SECRET => configFile[:SECRET]})
stream.finish
