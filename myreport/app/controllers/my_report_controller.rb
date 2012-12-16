class MyReportController < ApplicationController
  respond_to :json, :html
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
    @report_contents = {}
    @report_options  = {}
      # fixme. Folllowing method must be in model
    @report_contents = get_report_from_parameters params
    @report_options  = get_report_options_from_parameters params
    @user = session[:user]
    session[:report_contents] = @report_contents
    session[:report_options]  = @report_options
    if validate_report_contents && validate_report_options
      Rails.logger.info "[Preview] --------------------"
      Rails.logger.info @report_contents.inspect
      Rails.logger.info @report_options.inspect
      render "preview"
    else
      @errors = session[:errors]
      render "create"
    end
  end

  def sendReport
    # Fixme add common method and filter to pass session variables
    report_contents = session[:report_contents]
    report_options  = session[:report_options]
    report_options["email_type"] = params[:emailType]
    #mailType = params[:mailType]
    @user = session[:user]
    #@emailTo = validate_from_email @user['contact']['email_addresses'][0]['address']
      # ----- TEST MODE ----
    #@emailTo = "avinash.varma4464@gmail.com"
    Rails.logger.info "[SendReport] -------------------------------------------------------------"
    Rails.logger.info report_contents.inspect
    Rails.logger.info report_options.inspect
    @email_to   = validate_from_email report_options["email_to"]
    @email_from = validate_from_email report_options["email_from"] ? report_options["email_from"] : @user['contact']['email_addresses'][0]['address']
    #@email_from = validate_from_email "matil@test.com"
    unless @email_to and @email_from
      # Fixme add proper erro pages. Mostly in this case, the email address can be valid but outside address
      # DRY ki maa behan
      @report_contents = session[:report_contents]
      @error = "Email Error! check to address"
      render "preview"
    else
      #UserMailer.sendReport(@emailTo,session[:impression],session[:awesome],session[:painful],session[:tasks],session[:next_week_tasks], @email_from).deliver
      unless report_options["email_type"] == "text"
        UserMailer.sendReport(@email_to, report_contents, @email_from, @user, report_options).deliver
      else
        UserMailer.sendTextReport(@email_to, report_contents, @email_from, @user, report_options).deliver
      end
      # ----- TEST MODE ----
      #session.clear
      render "reportSent"
    end
  end

  def validate_from_email email
    #checking syntax of mail address
   email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
   # checking if the email address is internal email address
   # Fixme Add constant support
   #Constants::Mail::valid_send_address.include?(email.split("@")[1]) ? email : ""
    ["mail.rakuten.com", "mail.rakuten.co.jp"].include?(email.split("@")[1]) ? email : false
  end

  def get_report_from_parameters(params)
    @report_contents = {}
    @report_contents["impression"]      = params[:report][:impression]
    @report_contents["tasks"]           = params[:report][:tasks]
    @report_contents["next_week_tasks"] = params[:report][:next_week_tasks]
    @report_contents["other"]           = params[:report][:other]
    @report_contents
  end

  def get_report_options_from_parameters(params)
    @options = {}
    @options["email_to"]   = params[:emailTo]
    @options["email_from"] = params[:emailFrom]
    @options["cc"]         = params[:emailCc]
    @options
  end

  def validate_report_contents
    true
  end

  def validate_report_options
    true
  end

  def add_to_reminder_list
    # fix-me : add keyformat to constants
    key   = params[:day] + "-RemainderMailList-MyReport"
    email = params[:email]
    REDIS.rpush(key,email) if validate_from_email email
    # fix-me: add proper return type
    respond_with params
  end
end



=begin
      url = "http://www.avivarma.com:2929/myreports/"
      req = Weary::Request.new url, :POST
      req.params('{
        "report" : {
         "user": {
              "fullName": "avinash varma",
              "mugshotURL": "",
              "birthDate": "march 09",
              "email": "avinash.varma@mail.rakuten.com",
              "jobTitle": "Application Engineer",
              "department": "DU"
          },
          "contents": {
              "impression": "This week was good !",
              "tasksThisWeek": "none",
              "tasksNextWeek": "none"
          },
          "header": {
              "senderEmail": "avinash.varma@mail.rakuten.com",
              "targetEmail": "avinash.varma4464@gmail.com",
              "dateTo": "12102012",
              "dateFrom": "16102012",
              "sentDateTime": "16102012 00:09:90",
              "mailType": "html"
            }
          },


          "options": {
              "dateTo": "12102012",
              "dateFrom": "16102012",
              "email": "avinash.varma@mail.rakuten.com"
          }
      }')
      req.perform
=end
