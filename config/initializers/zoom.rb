require 'zoom'

Zoom.configure do |c|
  c.api_key = ENV['ZOOM_US_API_KEY']
  c.api_secret = ENV['ZOOM_US_API_SECRET']
end
zoom_client = Zoom.new
user_list = zoom_client.user_list
$zoom_user_id = user_list['users'][0]['id']
puts "Zoom.us user_id = #{$zoom_user_id}"