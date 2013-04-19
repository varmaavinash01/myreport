class MyReportController < ApplicationController
  respond_to :json, :html
  
  def create
    @user = session[:user]
  end

  def index
  end

  def login
  end

  def auth
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
      Rails.logger.info "[USER] = " + @user.to_json
      session[:user] = @user
      redirect_to :action=>'create'
    end 
  end

  def preview
    @report_contents = Report.build_report session, params
    @report_options  = Report.set_options  session, params
    @user = session[:user]
    
    unless Report.validate?
      @errors = session[:errors]
      render "create"
    end
  end

  def sendReport
    # Fixme add common method and filter to pass session variables
    report_contents = session[:report_contents]
    report_options  = session[:report_options]
    report_options["email_type"] = params[:emailType]
    @user = session[:user]
      # ----- TEST MODE ----
    #@emailTo = "avinash.varma4464@gmail.com"
    Rails.logger.info "[SendReport] -------------------------------------------------------------"
    Rails.logger.info report_contents.inspect
    Rails.logger.info report_options.inspect
    @email_to   = validate_from_email report_options["email_to"]
    @email_from = validate_from_email report_options["email_from"] || @user['contact']['email_addresses'][0]['address']
    if @email_to and @email_from
      if  report_options["email_type"] == "text"
        UserMailer.sendTextReport(@email_to, report_contents, @email_from, @user, report_options).deliver
      else
        UserMailer.sendReport(@email_to, report_contents, @email_from, @user, report_options).deliver
      end
      # ----- TEST MODE ----
      #session.clear
      render "reportSent"
    else
      # Fixme add proper erro pages. Mostly in this case, the email address can be valid but outside address
      # DRY ki maa behan
      @report_contents = session[:report_contents]
      @error = "Email Error! check 'TO' address"
      render "preview"
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

  def add_to_reminder_list
    # fix-me : add keyformat to constants
    key   = params[:day] + "-RemainderMailList-MyReport"
    email = params[:email]
    REDIS.rpush(key,email) if validate_from_email email
    # fix-me: add proper return type
    respond_with params
  end
end