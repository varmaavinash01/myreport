class Report
  class << self
    def build_report(session, params)
      session[:report_contents] = get_report_from_parameters params
    end
    
    def set_options(session, params)
      session[:report_options] =  get_report_options_from_parameters(params)
    end
    
    def send(session, email_to, email_from)
      report_contents = session[:report_contents]
      report_options  = session[:report_options]
      user = session[:user]

      if email_to and email_from
        if report_options["email_type"] == "text"
          UserMailer.sendTextReport(email_to, report_contents, email_from, user, report_options).deliver
        else
          UserMailer.sendHtmlReport(email_to, report_contents, email_from, user, report_options).deliver
        end
      else
        nil
      end
    end
    
    def check_remind_registered(email)
      key  = DateTime.now.strftime("%A") + "-RemainderMailList-MyReport"
      list = REDIS.lrange(key, 0, -1)
      list.include?(email)
    end
    
    def validate?
      validate_report_contents && validate_report_options
    end
    
    def set_email_type(session, email_type)
      session[:report_options]["email_type"]  = email_type
    end
  
    def validate_email(session, email_key)
      filter_email session[:report_options][email_key]
    end
    
    private
    def get_report_from_parameters(params)
      report_contents = {}
      report_contents["impression"]      = params[:report][:impression]
      report_contents["tasks"]           = params[:report][:tasks]
      report_contents["next_week_tasks"] = params[:report][:next_week_tasks]
      report_contents["other"]           = params[:report][:other]
      report_contents
    end
    
    def get_report_options_from_parameters(params)
      options = {}
      options["email_to"]   = params[:emailTo]
      options["email_from"] = params[:emailFrom]
      options["cc"]         = params[:emailCc]
      options
    end
    
    def validate_report_contents
      # validate session data for report_contents
      # add errors to session[:errors]
      true
    end
  
    def validate_report_options
      # validate session data for report_options
      # add errors to session[:errors]
      true
    end
    
  
    def filter_email(email)
      #checking syntax of mail address
     email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
     # checking if the email address is internal email address
     # Fixme Add constant support
     #Constants::Mail::valid_send_address.include?(email.split("@")[1]) ? email : ""
      ["mail.rakuten.com", "mail.rakuten.co.jp"].include?(email.split("@")[1]) ? email : nil
    end
    
  end
end