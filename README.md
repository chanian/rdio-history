# Rdio Player History
A simple set of Ruby scripts that helps you mine out your Rdio listening history.

## Disclaimer
I used this script to collect my personal listening history for a dataviz project. While there is an existing REST API which auths over oauth, the history end point is [not available at this time][request]. This script logs you into the web client, then re-uses the session tokens to authenticate and hit the existing history API endpoint.

Please use at own risk.

Rdio peeps, just let me know if this is a problem, I'll happily take this library down.

[request]: https://github.com/rdio/api/issues/13

## Example usage from Rake
    rake
    Enter username: chanian
    Enter password:
    
    40 Years Back Come - Röyksopp
    She's So - Röyksopp
    Remind Me - Röyksopp
    Royksopp's Night Out - Röyksopp
    A Higher Place - Röyksopp
    Poor Leno - Röyksopp
    In Space - Röyksopp
    Sparks - Röyksopp
    Eple (Original Edit) - Röyksopp
    So Easy - Röyksopp
    Animal - Pearl Jam

## Example usage from Library
```Ruby
  username = 'chanian'
  password = 'xxxxxx'
  # Fetch a set of live web auth tokens
  session = Rdio::Session::Fetcher.new(username, password)

  history = Rdio::History::Fetcher.new(session)
  history.fetch.each do |song|
    puts "#{song.name} - #{song.artist}"
  end
```

## Running tests
    rake spec

Have fun.
