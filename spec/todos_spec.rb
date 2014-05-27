require_relative 'spec_helper'


describe 'todos resource' do 

  it 'gets the correct content' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_equal 'It Works'
  end

end
