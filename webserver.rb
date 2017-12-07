#!/usr/bin/ruby
require 'sinatra'
require 'json'

require_relative 'hue'

set :run, true
set :port, 4567
set :bind, 'localhost'

IP = '10.64.12.80'
KEY = 'pUAUbcowosjBKgE5VQTrD6kkfkfoQK1ZtN14pHl8'


get '/' do
  content_type :html
  output = """<html>
  <script>

  function set_color(bulb, color) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/bulb/'+bulb+'/color/'+color);
    xhr.send(null);
  }
  function set_brightness(bulb, brightness) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/bulb/'+bulb+'/brightness/'+brightness);
    xhr.send(null);
  }
  function set_alert(bulb) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/bulb/'+bulb+'/alert');
    xhr.send(null);
  }
  </script>
  <style>
    .colors {

    input {
      font-size: 72px;
    }

    .content {
    max-width: 500px;
    margin: auto;
}

  </style>
  <head>
  <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/css/bootstrap.min.css\" integrity=\"sha384-PsH8R72JQ3SOdhVi3uxftmaW6Vc51MKb0q5P2rRUpPvrszuE4W1povHYgTpBfshb\" crossorigin=\"anonymous\">
  <script src=\"https://code.jquery.com/jquery-3.2.1.slim.min.js\" integrity=\"sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN\" crossorigin=\"anonymous\"></script>
  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.3/umd/popper.min.js\" integrity=\"sha384-vFJXuSJphROIrBnz7yo7oB41mKfc8JzQZiCq4NCceLEaO4IHwicKwpJf9c9IpFgh\" crossorigin=\"anonymous\"></script>
  <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta.2/js/bootstrap.min.js\" integrity=\"sha384-alpBpkh1PFOepccYVYDB4do5UnbKysX5WZXm3XxPqe5iKTfUKjNkCk9SaVuEZflJ\" crossorigin=\"anonymous\"></script>
 </head>

  <body>
  <div class=\"content\">
  <!-- Page content -->
  <table align=\"center\" >"""
  output += "<div class='colors'><h2><center>Bulb Colors</center></h2><br /><table class=\"table table-striped\">"
  ['Red'].each do |color|
    output += "<tr><td align=center>#{color}:</td>"
    [1,2].each do |bulb|
      output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(#{bulb},\"#{color}\")';><button type=\"button\" class=\"btn btn-danger\">#{bulb}</button> </a></td>"
    end
    output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(-1,\"#{color}\")';><button type=\"button\" class=\"btn btn-danger\"> Both bulbs </button> </a></td>"
    output += "</tr>"
  end
    ['Green'].each do |color|
      output += "<tr><td align=center>#{color}:</td>"
      [1,2].each do |bulb|
        output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(#{bulb},\"#{color}\")';><button type=\"button\" class=\"btn btn-success\">#{bulb}</button> </a></td>"
      end
      output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(-1,\"#{color}\")';><button type=\"button\" class=\"btn btn-success\"> Both bulbs </button> </a></td>"
      output += "</tr>"
  end
  ['Yellow'].each do |color|
    output += "<tr><td align=center>#{color}:</td>"
    [1,2].each do |bulb|
      output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(#{bulb},\"#{color}\")';><button type=\"button\" class=\"btn btn-warning\">#{bulb}</button> </a></td>"
    end
  output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(-1,\"#{color}\")';><button type=\"button\" class=\"btn btn-warning\"> Both bulbs </button> </a></td>"
    output += "</tr>"
end
['Blue'].each do |color|
  output += "<tr><td align=center>#{color}:</td>"
  [1,2].each do |bulb|
    output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(#{bulb},\"#{color}\")';><button type=\"button\" class=\"btn btn-primary\">#{bulb}</button> </a></td>"
  end
  output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(-1,\"#{color}\")';><button type=\"button\" class=\"btn btn-primary\"> Both bulbs </button> </a></td>"
  output += "</tr>"
end
['Cycles'].each do |color|
  output += "<tr><td align=center>#{color}:</td>"
  [1,2].each do |bulb|
    output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(#{bulb},\"#{color}\")';><button type=\"button\" class=\"btn btn-outline-danger\">#{bulb}</button> </a></td>"
  end
  output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_color(-1,\"#{color}\")';><button type=\"button\" class=\"btn btn-outline-danger\"> Both bulbs </button> </a></td>"
  output += "</tr>"
end
  output += "</table></div><div class='brightness'><h2><center>Brightness of Bulbs</center></h2><br /><table class=\"table table-striped\">"
  ['brightest', 'bright', 'low', 'lowest'].each do |brightness|
    output += "<tr><td align=center>#{brightness}:</td>"
    [1,2].each do |bulb|
      output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_brightness(#{bulb},\"#{brightness}\")';><button type=\"button\" class=\"btn btn-dark\">#{bulb}</button> </a></td>"
    end
    output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_brightness(-1,\"#{brightness}\")';><button type=\"button\" class=\"btn btn-dark\"> Both bulbs </button> </a></td>"
    output += "</tr>"
  end
    output += "</table></div><div class='alert'><h2><center>Flashing lights</center></h2><br /><table class=\"table table-striped\">"
    output += "<tr><td align=center> Alert:</td>"
  [1,2].each do |bulb|
    output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_alert(#{bulb})';><button type=\"button\" class=\"btn btn-outline-info\">#{bulb}</button> </a></td>"
  end
  output += "<td align=center>Bulb: <a href='javascript:void(0)' onclick='set_alert(-1)';><button type=\"button\" class=\"btn btn-outline-info\"> Both bulbs </button> </a></td>"
  output += "</tr>"
  output += "</table></div>"
  output += "</body></html>"
  output += "</div>"
  response['Access-Control-Allow-Origin'] = '*'
  output


end


get '/state/*' do
 content_type :json
 response['Access-Control-Allow-Origin'] = '*'
 bulb_num = params['splat'].first.to_i
 puts "getting state for #{bulb_num}"
 {"status" => state(IP, bulb_num, KEY)}.to_json
end

get '/bulb/*/color/*' do
  content_type :json
  response['Access-Control-Allow-Origin'] = '*'
  bulb_num = params['splat'].first.to_i
  color = params['splat'].last
  puts "getting bulb no. #{bulb_num}"
  {"color" => color(IP, bulb_num, KEY, color)}.to_json
 end

 get '/bulb/*/brightness/*' do
   content_type :json
   response['Access-Control-Allow-Origin'] = '*'
   bulb_num = params['splat'].first.to_i
   brightness = params['splat'].last
   {"brightness" => brightness(IP, bulb_num, KEY, brightness)}.to_json
  end

  get '/bulb/*/alert' do
    content_type :json
    response['Access-Control-Allow-Origin'] = '*'
    bulb_num = params['splat'].first.to_i
    color = params['splat'].last
    {"color" => alert(IP, bulb_num, KEY)}.to_json
  end
