#!/usr/bin/env ruby
require 'sinatra'

set port: 9001
set server: 'thin'

connections = []

before do
    content_type :txt
end

get '/status' do
    status 200
end

get '/connect', provides: 'text/event-stream' do
    stream(:keep_open) do |connection|
        connections << connection
        connection.callback { connections.delete(connection) }
        connection.errback { connections.delete(connection) }
    end
end

post '/send' do
    connections.each do |connection|
        connection << "#{params[:message]} \r"
    end
end

