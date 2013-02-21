require 'rake'
require 'highline/import'
require 'colorize'
require 'lib/rdio-history'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc "Ask the user for their Rdio username/password"
task :get_user do
  @username = ask("Enter username: ")
  @password = ask("Enter password: ") { |q| q.echo = false }
end

desc "Auth then retreive the most recent songs"
task :default => [:get_user] do
  begin
    session = Rdio::Session::Fetcher.get_session(@username, @password)
  rescue Rdio::Session::SessionException => se
    puts se.message.red
    exit
  end

  f = Rdio::History::Fetcher.new(session)
  f.fetch.each do |song|
    puts "#{song.name} - #{song.artist}"
  end
end

desc "Fetch a single long lived session"
task :get_session => [:get_user] do
  session = Rdio::Scraper.get_session(@username, @password)
  puts "user_id: #{session[:user_id]}"
  puts "authorization_key: #{session[:authorization_key]}"
  puts "authorization_cookie: #{session[:authorization_cookie]}"
end

task :test => :spec