class MyReportController < ApplicationController
  
  def create
    #require 'mongo'
    #db = Mongo::Connection.new.db("mydb") # OR
    connection = Mongo::Connection.new("localhost", 27017)
    db = connection.db("mydb")
    Rails.logger.info "connection => " + connection.to_s
    Rails.logger.info "connection.database_names => " + connection.database_names.to_s
    #Report.create(:title => 'Weekly report', :sender_email => 'avinash.varma4464@gmail.com')
    
  end
  
  def index

  end
  def login
    Rails.logger.info "Login called. Prepare to call yammer authentication"
    

  end
  
  def auth    
    Rails.logger.info "auth called"
    token = params[:code] 
    url = "https://www.yammer.com/oauth2/access_token.json?client_id=7HbmqEWoS7at6ID0pemSg&client_secret=nVccg50Zlk6YxWg5uiQutqCkMYxucf5Nyx89zNYc&code="+token
    req = Weary::Request.new url, :GET
    @result = req.perform
    @body = ActiveSupport::JSON.decode @result.body
    @user = @body["user"]
    #render @result.to_json
  end
end
