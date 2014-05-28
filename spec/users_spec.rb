require_relative 'spec_helper'


describe 'Api::V1::Scheduler' do 
  describe 'POST /api/v1/users' do 
    it 'creates a new user if all fields are valid' do 
      user = {:email => 'foo@example.com', :password => 'pass'}
      result = post_json '/api/v1/users', user
      last_response.status.must_equal 200
      result[:status].must_equal 201
      result[:message].must_equal "User created successfully"
      DB[:users].count.must_equal 1
    end

    it 'encrypts users password' do 
      user = {:email => 'foo@example.com', :password => 'pass'}
      result = post_json '/api/v1/users', user
      last_response.status.must_equal 200
      result[:status].must_equal 201
      result[:message].must_equal "User created successfully"
      DB[:users].count.must_equal 1
      User[:email => user[:email]].password.wont_equal user[:password]
    end

    it 'does not create invalid users' do 
      user = {:email => ''}
      result = post_json '/api/v1/users', user
      last_response.status.must_equal 200
      result[:status].must_equal 412
      result[:message].must_equal 'Invalid Record'  
      result[:errors][:email].must_include 'cant be blank'
      result[:errors][:password].must_include 'cant be blank'
    end
  end

end
