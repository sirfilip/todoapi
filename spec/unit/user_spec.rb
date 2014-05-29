require File.expand_path('../../spec_helper', __FILE__)



describe User do 

  it 'must have a valid email address' do 
    user = User.new
    user.email = ''
    user.wont_be :valid?
    user.errors.keys.must_include :email
    user.email = 'someinvalidemail'
    user.errors.keys.must_include :email
    user.wont_be :valid?
    user.email = 'example@dot.com'
    user.valid?
    user.errors.keys.wont_include :email
  end
  
  it 'must have a password' do 
    user = User.new 
    user.wont_be :valid?
    user.errors.keys.must_include :password
    user.password = 'some password'
    user.valid?
    user.errors.wont_include :password
  end

end
