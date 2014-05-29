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
    
      use Warden::Manager do |manager|
        manager.default_strategies :token, :password
        manager.failure_app = lambda {|env| [200, {'Content-type' => 'application/json'}, [env['warden'].message || '{"status": 401, "message":"Login required"}']]}
      end
      
      Warden::Strategies.add(:token) do 
        def valid?
          params["token"]
        end
        
        def authenticate!
          u = User[:token => params["token"]]
          u.nil? ? fail!('{"status": 401, "message":"Login required"}') : success!(u) 
        end
      end
      
      Warden::Strategies.add(:password) do 
        def data
          request.body.rewind
          JSON.parse(request.body.read, :symbolize_names => true)
        end
        
        def valid?
          data[:email] && data[:password]
        end
        
        def authenticate!
          user = User[:email => data[:email]]
          if user and user.password == Hasher.encrypt(data[:password])
            user.token = Hasher.encrypt("#{user.id}:#{user.email + Time.now.to_s}")
            user.save
            success!(user) 
          else
            fail!('{"status": 412, "message":"Wrong email and password combination"}')
          end
        end
      end
    
    
    
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
        
        def warden
          env['warden']
        end
        
        def authenticate!
          warden.authenticate! :token
        end
        
        def current_user
          warden && warden.user 
        end
      end


      post '/api/v1/users' do 
        data = json_input
        password = Hasher.encrypt(data[:password]) if data[:password]
        user = User.new(:email => data[:email], :password => password)
        if user.save
          respond_with({:status => 201, :message => 'User created successfully'}, {:login_url => '/api/v1/session'})
        else
          respond_with({:status => 412, :message => 'Invalid Record', :errors => user.errors})
        end
      end

      post '/api/v1/session' do
        warden.authenticate! :password
        respond_with({:status => 201, :message => 'Login successful', :token => warden.user.token}) 
      end

      delete '/api/v1/session' do 
        authenticate!
        current_user.token = nil
        current_user.save
        respond_with({:status => 200, :message => 'Logout successfull'})
      end


      get '/api/v1/todos' do
        authenticate! 
        DB[:todos].all.to_json
      end
    end
  end
end
