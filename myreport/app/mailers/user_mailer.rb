class UserMailer < ActionMailer::Base

  def sendHtmlReport(emailId, report_contents, from, user, options)
    @from            = from
    @report_contents = report_contents
    @emailTo         = emailId
    @user            = user
    @mailCc          = options['cc']
    subject = "[Weekly Report] " + @user['full_name']  + " | " +  @user['job_title'] + " |  "  +  @user['department']
    # Fix me  find if any way to replace @

    Rails.logger.info "\n\nSending mail now ... " + report_contents.to_json
    Rails.logger.info "\n\options ... " + options.to_json

    if mail(
             :to => emailId,
             :cc => @mailCc,
             :subject =>  subject,
             :from => from,
             :template_path => 'my_report',
             :template_name => '_preview_shared'
           )
      logger.debug "[SUCCESS] from user_mailer mailSent"
    else
      logger.debug "[ERROR] Mail sending failed"
    end
  end

  def sendTextReport(emailId, report_contents, from, user, options)
    @from            = from
    @report_contents = report_contents
    @emailTo         = emailId
    @user            = user
    @mailCc          = options['cc']
    subject = "[Weekly Report] " + @user['full_name']  + " | " +  @user['job_title'] + " |  "  +  @user['department']

    # Fix me  find if any way to replace @
    
    Rails.logger.info "\n\nSending mail now ... " + report_contents.to_json
    Rails.logger.info "\n\options ... " + options.to_json
    
    if mail(
             :to => emailId,
             :cc => @mailCc,
             :subject => subject,
             :from => from,
             :template_path => 'my_report',
             :template_name => '_preview_shared.text.erb'
           )
      logger.debug "[SUCCESS] from user_mailer mailSent"
    else
      logger.debug "[ERROR] Mail sending failed"
    end
  end

end
