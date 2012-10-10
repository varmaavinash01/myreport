class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def sendReport(emailId, report_contents, from, user)
    @from            = from
    @report_contents = report_contents
    @emailTo         = emailId
    @user            = user
    # Fix me  find if any way to replace @
    Rails.logger.info "\n\nSending mail now ... " + report_contents.to_json
    if mail(:to => emailId, :subject => '[Weekly Report] Avinash Varma | Engineer ', :from => from)
      logger.debug "[SUCCESS] from user_mailer mailSent"
    else
      logger.debug "[ERROR] Mail sending failed"
    end
  end

  def sendTextReport(emailId, report_contents, from)
    @from            = from
    @report_contents = report_contents
    @emailTo         = emailId
    # Fix me  find if any way to replace @
    Rails.logger.info "\n\nSending mail now ... " + report_contents.to_json
    if mail(:to => emailId, :subject => '[Weekly Report] Avinash Varma | Engineer ', :from => from)
      logger.debug "[SUCCESS] from user_mailer mailSent"
    else
      logger.debug "[ERROR] Mail sending failed"
    end
  end


end
