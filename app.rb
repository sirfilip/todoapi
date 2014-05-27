require 'bundler'

Bundler.setup
Bundler.require

Sequel.sqlite

get '/' do 
  'It Works'
end
