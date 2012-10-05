class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def sendReport(emailId, impression, awesome, painful, tasks, next_week_tasks, from)
    @impression      = impression
    @awesome         = awesome
    @painful         = painful
    @tasks           = tasks
    @next_week_tasks = next_week_tasks
    @from            = from
    if mail(:to => emailId, :subject => '[Weekly Report] Avinash Varma | Engineer ', :from => from)
      logger.debug "[SUCCESS] from user_mailer mailSent"
    else
      logger.debug "[ERROR] Mail sending failed"
    end
  end
end
