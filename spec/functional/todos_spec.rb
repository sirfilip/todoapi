require File.expand_path('../../spec_helper', __FILE__)


describe 'Api::V1::Scheduler' do

  before do 
    @user = User.create(:email => 'example@dot.com', :password => Hasher.encrypt('pass'))
    post_json 'api/v1/session', {:email => @user.email, :password => 'pass'}
    @user.reload
  end

  describe 'GET /api/v1/todos' do
  
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

    it 'provides meta with additional info' do 
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
      result[:_meta][:total].must_equal 1
      result[:_meta][:offset].must_equal 0
      result[:_meta][:limit].must_equal 50
      result[:_meta][:order].must_equal 'id'
    end

    it 'provides proper 500 page' do 
      result = get_json "/api/v1/todos?token=#{@user.token}&limit=asfasdfasfasfasdf"
      result[:status].must_equal 500
      result[:message].must_equal 'Server Error'
    end
  end
  
  describe 'POST /api/v1/todos' do
   
    it 'creates todo' do 
      todo_params = {
        :description => 'A todo'
      }
      result = post_json "/api/v1/todos?token=#{@user.token}", todo_params
      result[:status].must_equal 201
      result[:message].must_equal 'Todo created successfully'
      Todo[:id => result[:todo][:id]].values.must_equal result[:todo]
      result[:todo][:user_id].must_equal @user.id
    end
    
    it 'fails to create invalid todo' do 
      result = post_json "/api/v1/todos?token=#{@user.token}", {:description => nil}
      result[:status].must_equal 412
      result[:message].must_equal 'Invalid Record'
      result[:errors][:description].must_include 'cant be blank'
    end

  end

  describe 'GET /api/v1/todos/:id' do 
    it 'shows user owned todo' do 
      todo = Todo.new(:description => 'todo')
      todo.user_id = @user.id
      todo.save
      result = get_json "/api/v1/todos/#{todo.id}?token=#{@user.token}"
      result[:status].must_equal 200
      result[:todo].must_equal todo.values
    end

    it 'does not show todos not owned by user' do 
      todo = Todo.new(:description => 'todo')
      todo.user_id = 0
      todo.save
      result = get_json "/api/v1/todos/#{todo.id}?token=#{@user.token}"
      result[:status].must_equal 404
      result[:message].must_equal 'Not Found'
    end

    it 'shows 404 page for non-existing todo' do 
      result = get_json "/api/v1/todos/42?token=#{@user.token}"
      result[:status].must_equal 404
      result[:message].must_equal 'Not Found'
    end
  end

  describe 'PUT /api/v1/todos/:id' do 
    it 'updates the todo with a valid data if owned by user' do
      todo = Todo.new(:description => 'change me')
      todo.user_id = @user.id
      todo.save
      result = put_json "/api/v1/todos/#{todo.id}?token=#{@user.token}", {:description => 'a brand new description'}
      todo.reload
      result[:status].must_equal 200
      result[:message].must_equal 'Todo updated successfully'
      todo.description.must_equal 'a brand new description'
      todo.values.must_equal result[:todo]
    end

    it 'does not update the todo if not owned by user' do
      todo = Todo.new(:description => 'change me')
      todo.user_id = 0
      todo.save
      result = put_json "/api/v1/todos/#{todo.id}?token=#{@user.token}", {:description => 'a brand new description'}
      todo.reload
      result[:status].must_equal 404
      result[:message].must_equal 'Not Found'
      todo.description.wont_equal 'a brand new description'
    end

    it 'does not update the todo if data is invalid' do
      todo = Todo.new(:description => 'change me')
      todo.user_id = @user.id
      todo.save
      result = put_json "/api/v1/todos/#{todo.id}?token=#{@user.token}", {:description => nil}
      todo.reload
      result[:status].must_equal 412
      result[:message].must_equal 'Invalid Record'
      result[:errors][:description].must_include 'cant be blank'
    end

    it 'ignores all extra params passed' do
      todo = Todo.new(:description => 'change me')
      todo.user_id = @user.id
      todo.save
      result = put_json "/api/v1/todos/#{todo.id}?token=#{@user.token}", {:description => 'a brand new description', :user_id => 12, :non_existing_field => 'fubar'}
      todo.reload
      result[:status].must_equal 200
      result[:message].must_equal 'Todo updated successfully'
      todo.description.must_equal 'a brand new description'
      todo.values.must_equal result[:todo]
      todo.user_id.must_equal @user.id
    end
  end

  describe 'DELETE /api/v1/todos/:id' do
    it 'deletes a todo owned by a user' do 
      todo = Todo.new(:description => 'desc')
      todo.user_id = @user.id
      todo.save
      id = todo.id
      result = delete_json "/api/v1/todos/#{id}?token=#{@user.token}"
      result[:status].must_equal 200
      result[:message].must_equal "Todo deleted successfully"
      Todo[:id => id].must_be_nil
    end

    it 'does not delete a record if not owned by user' do
      todo = Todo.new(:description => 'desc')
      todo.user_id = 0
      todo.save
      id = todo.id
      result = delete_json "/api/v1/todos/#{id}?token=#{@user.token}"
      result[:status].must_equal 404
      result[:message].must_equal "Not Found"
      Todo[:id => id].wont_be_nil
    end
  end
end
