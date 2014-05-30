require File.expand_path('../../spec_helper', __FILE__)

describe Todo do 

  it 'must have a description' do
    todo = Todo.new 
    todo.wont_be :valid?
    todo.errors[:description].must_include 'cant be blank'
  end
  
  it 'must have a user' do
    todo = Todo.new 
    todo.wont_be :valid?
    todo.errors[:user_id].must_include 'cant be blank'
  end

end
