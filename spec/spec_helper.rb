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

  def post_json(url, data)
    post(url, data.to_json, { "CONTENT_TYPE" => "application/json" })
    JSON.parse(last_response.body, :symbolize_names => true)
  end

  def get_json(url)
    get url 
    JSON.parse(last_response.body)
  end
end



def app
  Api::V1::Scheduler
end
