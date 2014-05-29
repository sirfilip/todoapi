require 'bundler'

Bundler.setup
Bundler.require

require 'json'

DB = Sequel.sqlite

DB.create_table :todos do 
  Integer :id, :primary_key => true
  String :description
  Integer :user_id
  Integer :priority, :default => 0
  Boolean :done, :default => false
end unless DB.table_exists?(:todos)

DB.create_table :users do 
  Integer :id, :primary_key => true
  String :email, :unique => true
  String :password
  String :token
end unless DB.table_exists?(:users)

Sequel::Model.raise_on_save_failure = false

class User < Sequel::Model
  plugin :validation_helpers
  set_allowed_columns(:email, :password)


  def validate
    super
    validates_presence [:email, :password], :message => 'cant be blank'
    validates_unique :email, :message => 'already taken'
    validates_format /.+@.+\.(com|net|org)/, :email, :message => 'not a valid email'
  end
end

require 'digest/sha1'

class Hasher

  SECRET = 'a secret'

  def self.encrypt(str)
    Digest::SHA1.hexdigest(SECRET + str)
  end

end

module Api
  module V1
    class Scheduler < Sinatra::Base
      helpers do 
        def json_input
          request.body.rewind
          JSON.parse(request.body.read, :symbolize_names => true)
        end

        def respond_with(data, _meta = {})
          status 200
          content_type :json
          data[:_meta] = _meta
          data.to_json
        end
      end


      post '/api/v1/users' do 
        data = json_input
        password = Hasher.encrypt(data[:password]) if data[:password]
        user = User.new(:email => data[:email], :password => password)
        if user.save
          respond_with({:status => 201, :message => 'User created successfully'})
        else
          respond_with({:status => 412, :message => 'Invalid Record', :errors => user.errors})
        end
      end

      post '/api/v1/session' do
        data = json_input
        user = User[:email => data[:email]]
        if user and user.password == Hasher.encrypt(data[:password])
          user.token = Hasher.encrypt("#{user.id}:#{user.email + Time.now.to_s}")
          user.save
          respond_with({:status => 201, :message => 'Login successful', :token => user.token})
        else
          respond_with({:status => 412, :message => 'Wrong email/password combination'})
        end 
      end

      delete '/api/v1/session' do 
      end


      get '/api/v1/todos' do 
        DB[:todos].all.to_json
      end
    end
  end
end
