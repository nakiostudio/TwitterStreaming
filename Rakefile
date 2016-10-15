require 'rake'
require 'net/http'

namespace :sinatra do

    desc 'Runs the stub server'
    task :start do
        puts 'Running server...'
        `thin -s 1 -C Sinatra/config.yml start`
        puts 'Streaming...'
        pid = `nohup bundle exec ruby Sinatra/streamer.rb > Sinatra/streamer.log 2>&1 &`
    end

    desc 'Kills the process of our stub server'
    task :stop do
        puts 'Killing processes...'
        `kill -9 $(cat Sinatra/sinatra.9001.pid)`
        `rm Sinatra/sinatra.9001.pid`
    end

    desc 'Shows the latest logs of our stub server'
    task :logs do
        exec('tail -f Sinatra/server.9001.log')
    end

end
