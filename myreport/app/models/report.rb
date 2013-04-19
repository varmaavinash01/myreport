class Report
  class << self
    def build_report(session, params)
      session[:report_contents] = get_report_from_parameters params
    end
    
    def set_options(session, params)
      session[:report_options] =  get_report_options_from_parameters(params)
    end
    
    def check_remind_registered(email)
      key  = DateTime.now.strftime("%A") + "-RemainderMailList-MyReport"
      list = REDIS.lrange(key, 0, -1)
      list.include?(email)
    end
    
    def validate?
      validate_report_contents && validate_report_options
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
    
  end
end