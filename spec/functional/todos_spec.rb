require File.expand_path('../../spec_helper', __FILE__)


describe 'Api::V1::Scheduler' do

  describe 'GET /api/v1/todos' do

    it 'gets the correct content' do
      todo = {
        'description' => 'Create an api',
        'user_id' => 1,
        'priority' => 0,
        'done' => false
      }
      todo['id'] = DB[:todos].insert(todo)
      get '/api/v1/todos'
      last_response.must_be :ok?
      JSON.parse(last_response.body).must_equal [todo]
    end

  end
end
