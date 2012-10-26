class UserMailer < ActionMailer::Base
 
  def sendReport(emailId, report_contents, from, user)
    @from            = from
    @report_contents = report_contents
    @emailTo         = emailId
    @user            = user
    subject = "[Weekly Report] " + @user['full_name']  + " | " +  @user['job_title'] + " |  "  +  @user['department']
    # Fix me  find if any way to replace @
    Rails.logger.info "\n\nSending mail now ... " + report_contents.to_json
    if mail(:to => emailId, :subject =>  subject, :from => from)
      logger.debug "[SUCCESS] from user_mailer mailSent"
    else
      logger.debug "[ERROR] Mail sending failed"
    end
  end

  def sendTextReport(emailId, report_contents, from, user)
    @from            = from
    @report_contents = report_contents
    @emailTo         = emailId
    @user            = user
    subject = "[Weekly Report] " + @user['full_name']  + " | " +  @user['job_title'] + " |  "  +  @user['department']
      
    # Fix me  find if any way to replace @
    Rails.logger.info "\n\nSending mail now ... " + report_contents.to_json
    if mail(:to => emailId, :subject => subject, :from => from)
      logger.debug "[SUCCESS] from user_mailer mailSent"
    else
      logger.debug "[ERROR] Mail sending failed"
    end
  end
  
end
