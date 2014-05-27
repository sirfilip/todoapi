ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'minitest/autorun'
require 'database_cleaner'
require 'rack/test'

DatabaseCleaner.strategy = :transaction

class MiniTest::Spec
  include Rack::Test::Methods

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end



def app
  Sinatra::Application
end
