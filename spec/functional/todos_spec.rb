require File.expand_path('../../spec_helper', __FILE__)


describe 'Api::V1::Scheduler' do

  describe 'GET /api/v1/todos' do
  
    before do 
      @user = User.create(:email => 'example@dot.com', :password => Hasher.encrypt('pass'))
      post_json 'api/v1/session', {:email => @user.email, :password => 'pass'}
      @user.reload
    end
  
    it 'gets the correct content' do
      todo = {
        'description' => 'Create an api',
        'user_id' => @user.id,
        'priority' => 0,
        'done' => false
      }
      todo['id'] = DB[:todos].insert(todo)
      result = get_json "/api/v1/todos?token=#{@user.token}"
      result.must_equal [todo]
    end

  end
end
