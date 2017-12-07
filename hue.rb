#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'uri'
require 'faraday'
require 'pry'
require 'optparse'

options = {}

# sends the command to the hue hub and checks for errors
def send_command(ip, url, key, message)
  connection = Faraday.new(:url => "http://#{ip}/api/#{key}", :ssl => { :verify => false })
  if message == ""
    response = connection.get(url)
  else
    response = connection.put(url, message.to_json)
  end
  if response.status != 200 or response.body.include?('error')
    raise("Error sending command.\nuri: #{url}\nmessage: #{message}\nresponse: #{response.body}")
  end
  return response
end

def alert(ip, bulb_number, key)
  url     = "lights/#{bulb_number}/state"
  if bulb_number == -1
    url= "groups/2/action"
  end
  message = { "alert" => "lselect" }
  send_command(ip, url, key, message)
end

def state(ip, bulb_number, key)
 url     = "lights"
 raw_response = send_command(ip, url, key, "")
 response  = JSON.parse(raw_response.body)
 puts "got state"
 output =  "Light bulbs state is:"
 response.each do |light|
   output += "\nbulb number " + light.first.to_s
   output +=  "\nis bulb turned on? " + light.last['state']['on'].to_s
   output +=  "\nHue of bulb " + light.last['state']['hue'].to_s
   if light.last['state']['hue'] == 0
     output +=  "\nThe color is red."
   elsif  light.last['state']['hue'] == 46920
     output +=  "\nThe color is blue."
   elsif  light.last['state']['hue'] == 25500
     output +=  "\nThe color is Green."
   elsif  light.last['state']['hue'] == 12750
     output +=  "\nThe color is Yellow."
   elsif  light.last['state']['hue'] == 14956
     output +=  "\nThe color is normal light."
   elsif  light.last['state']['hue'] == 64100
     output +=  "\nThe color is pink."
   end
   output +=  "\nBrightness of bulb " + light.last['state']['bri'].to_s
   if light.last['state']['bri'] == 254
     output +=  "\nBulb is at its brightest"
   elsif light.last['state']['bri'] <=253 && light.last['state']['bri'] >=81
     output +=  "\nBulb is moderately bright"
   elsif light.last['state']['bri'] <= 80 && light.last['state']['bri'] >=21
     output +=  "\nBulb is realtively dim"
   elsif light.last['state']['bri'] <= 20 && light.last['state']['bri'] >=1
     output +=  "\nBulb is very dim"
   elsif light.last['state']['bri'] =0
     output +=  "\nBulb is at its dimmest"
   end
   output +=  "\nAlert?  " + light.last['state']['alert'].to_s
   output +=  "\nblob of info " + light.last['state'].to_s
   output +=  "\n"
 end
 puts output
 return output
end

def color(ip, bulb_number, key, color)
  url = "lights/#{bulb_number}/state"
  if bulb_number == -1
    url= "groups/2/action"
  end
  colors = []
  if color == 'Red'
    colors << 0
  elsif color == 'Blue'
    colors << 46920
  elsif color == 'Green'
    colors << 25500
  elsif  color == 'Yellow'
    colors << 12750
  elsif color == 'normal'
    colors << 14956
  elsif color == 'pink'
    colors <<  64100
  elsif color == 'Cycles'
    [0,46920,25500,12750,64100].each do |index|
      colors << index
    end
  else
    colors << color.to_i
  end


  colors.each do |color|
    message = { "hue" => color }
    send_command(ip, url, key, message)
    sleep(1)
  end
end

def brightness(ip, bulb_number, key, brightness)
  url = "lights/#{bulb_number}/state"
  if bulb_number == -1
    url= "groups/2/action"
  end

  if brightness == 'brightest'
    bri = 254
  elsif brightness == 'bright'
    bri = 150
  elsif brightness == 'low'
    bri = 80
  elsif brightness == 'lowest'
    bri = 20
  elsif brightness == 'changing'
    (1..200).each do |index|
      message = { "bri" => index }
    end
  else
    bri = brightness.to_i
  end
    message = { "bri" => bri }
    puts message
    send_command(ip, url, key, message)
end

# parser = OptionParser.new do |opts|
#   opts.banner = 'Usage: hue.rb [options]'
#
#   opts.on('-i', '--ip NAME', 'IP address of the hue hub. Required.') {|v| options[:ip] = v}
#   opts.on('-k', '--key KEY', 'Auth key for hub API. Required') {|v| options[:key] = v}
#   opts.on('-n', '--bulb_number NUMBER', 'bulb number. Required') {|v| options[:bulb_number] = v}
#   opts.on('-c', '--color COLOR', 'change color can be a number 0-65535 or pick red|green|blue') {|v| options[:color] = v}
#   opts.on('-b', '--brightness NUMBER', 'change brighness 0-254') {|v| options[:brightness] = v}
#   opts.on('-a', '--alert', 'send an alert') {|v| options[:alert] = true}
#   opts.on('-s', '--state', 'check if the light is on or off') {|v| options[:state] = true}
#
# end
#
# parser.parse!
# if options.empty?
#   puts parser
#   exit
# end
#
#
# if options[:ip].nil?
#   puts "ERROR: No IP Address specified."
#   puts "Use --help to find info on command line arguments."
#   exit
# end
#
# if options[:key].nil?
#   puts "ERROR: No API Key specified."
#   puts "Use --help to find info on command line arguments."
#   exit
# end
#
# if options[:bulb_number].nil?
#     options[:bulb_number]= -1
# end
#
# if options[:alert]
#   alert(options[:ip], options[:bulb_number], options[:key])
# end
# if options[:color]
#   color(options[:ip], options[:bulb_number], options[:key], options[:color])
# end
# if options[:brightness]
#   brightness(options[:ip], options[:bulb_number], options[:key], options[:brightness])
# end
# if options[:state]
#   state(options[:ip], options[:bulb_number], options[:key])
# end
