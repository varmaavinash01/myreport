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
    unless params[:error].blank?
      Rails.logger.info "Yammer Auth Error" + params[:error] + params[:error_description]
      render 'authError'
    else
      token = params[:code]
      url   = "https://www.yammer.com/oauth2/access_token.json?client_id=7HbmqEWoS7at6ID0pemSg&client_secret=nVccg50Zlk6YxWg5uiQutqCkMYxucf5Nyx89zNYc&code=" + token
      #url  = Constants::URL::yammer_url+token
      req   = Weary::Request.new url, :GET

      @result = req.perform
      @body   = ActiveSupport::JSON.decode @result.body
      @user   = @body["user"]
      Rails.logger.info @user.to_json
      session[:user] = @user
      render 'create'
    end # Auth success if closed
  end

  def preview
    report_contents = {}
      # fixme. Folllowing method must be in model
    report_contents = get_report_from_parameters params
    @user = session[:user]
    session[:report_contents] =  report_contents
    render "preview"
  end

  def sendReport
    # Fixme add common method and filter to pass session variables
    mailType = params[:mailType]
    @user = session[:user]
    @emailTo = validate_from_email @user['contact']['email_addresses'][0]['address']
    @email_from = validate_from_email @user['contact']['email_addresses'][0]['address']
    #@email_from = validate_from_email "matil@test.com"
    report_contents = session[:report_contents]
      Rails.logger.info "email_from = " + @email_from.to_s
    if @email_from == ""
      # Fixme add proper erro pages. Mostly in this case, the email address can be valid but outside address
      render "error"
    else
      #UserMailer.sendReport(@emailTo,session[:impression],session[:awesome],session[:painful],session[:tasks],session[:next_week_tasks], @email_from).deliver
      unless mailType == "text"
        UserMailer.sendReport(@emailTo, report_contents, @email_from, @user).deliver
      else
        UserMailer.sendTextReport(@emailTo, report_contents, @email_from, @user).deliver
      end
      session.clear
      render "reportSent"
    end
  end

  def validate_from_email email
    #checking syntax of mail address
   email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
   # checking if the email address is internal email address
   # Fixme Add constant support
   #Constants::Mail::valid_send_address.include?(email.split("@")[1]) ? email : ""
    ["mail.rakuten.com", "mail.rakuten.co.jp"].include?(email.split("@")[1]) ? email : ""
  end

  def get_report_from_parameters(params)
    @report_contents = {}
    @report_contents["impression"]      = params[:report][:impression]
    @report_contents["awesome"]         = params[:report][:awesome]
    @report_contents["painful"]         = params[:report][:painful]
    @report_contents["tasks"]           = params[:report][:tasks]
    @report_contents["next_week_tasks"] = params[:report][:next_week_tasks]
    @report_contents
  end
end
