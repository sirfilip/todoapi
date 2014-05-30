require File.expand_path('../../spec_helper', __FILE__)


describe 'Api::V1::Scheduler' do

  describe 'GET /api/v1/todos' do
  
    before do 
      @user = User.create(:email => 'example@dot.com', :password => Hasher.encrypt('pass'))
      post_json 'api/v1/session', {:email => @user.email, :password => 'pass'}
      @user.reload
    end
  
    it 'gets the correct content' do
      users_todo = Todo.new(
        :description => 'Create an api',
        :priority => 0,
        :done => false
      )
      users_todo.user_id = @user.id
      users_todo.save
      others_todo = Todo.new(
        :description => 'Create an api',
        :priority => 0,
        :done => false
      )
      others_todo.user_id = 0
      others_todo.save
      result = get_json "/api/v1/todos?token=#{@user.token}"
      result[:todos].must_include users_todo.values
      result[:todos].wont_include others_todo.values
    end

  end
end
