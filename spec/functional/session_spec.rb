require File.expand_path('../../spec_helper', __FILE__)


describe 'api/v1/session' do 

  describe 'post api/v1/session' do 
    it 'login' do 
      user = User.new(:email => 'example@dot.com', :password => Hasher.encrypt('pass'))
      user.save
      result = post_json '/api/v1/session', {:email => user.email, :password => 'pass'}
      last_response.status.must_equal 200
      result[:status].must_equal 201
      result[:message].must_equal 'Login successful'
      user.reload
      result[:token].must_equal user.token
    end
    
    it 'does not login' do 
      user = User.new(:email => 'example@dot.com', :password => Hasher.encrypt('pass'))
      user.save
      result = post_json '/api/v1/session', {:email => 'wrongemail', :password => 'wrongpass'}
      last_response.status.must_equal 200
      result[:status].must_equal 412
      result[:message].must_equal 'Wrong email/password combination'
    end
  end

end
