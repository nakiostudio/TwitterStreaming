#!/usr/bin/env ruby

# Performs request continuously to the stub environment to feed the connected
# clients with some data
while true
    (1..100).each do |i|
        puts "Sending item: #{i}"
        Net::HTTP.post_form(URI.parse('http://127.0.0.1:9001/send'), { message: "{\"item\":#{i}}" })
        sleep(2)
    end
end
