class MyReportController < ApplicationController
  respond_to :json, :html
  require 'jiraSOAP'
  def create
    @user = session[:user]
    jira = JIRA::JIRAService.new 'https://rakuten.atlassian.net/'
    
    jira.login "avinash.varma", REDIS.get("jira")
    #@issues = jira.issues_from_filter_with_id 15527
    @auth = jira.auth_token
    @gen = JIRA::IssueProperty
    @issues_this_week = jira.issues_from_jql_search "(assignee = currentUser() OR assignee was currentUser() OR reporter = currentUser()) AND updatedDate >= startOfWeek() AND updatedDate <= now() AND timespent >= 1"
    @issues_future    = jira.issues_from_jql_search "assignee = currentUser() AND resolution = Unresolved and priority >= Major" 
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
    @user = session[:user]
    @email_to   = Report.validate_email session, 'email_to'
    @email_from = Report.validate_email session, 'email_from' || @user['contact']['email_addresses'][0]['address']
    Report.set_email_type(session, params[:emailType])
    
      # ----- TEST MODE ----
    #@emailTo = "avinash.varma4464@gmail.com"
    if Report.send(session, @email_to, @email_from)
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

  def add_to_reminder_list
    # fix-me : add keyformat to constants
    key   = params[:day] + "-RemainderMailList-MyReport"
    email = params[:email]
    REDIS.rpush(key,email)
    # fix-me: add proper return type
    respond_with params
  end
end