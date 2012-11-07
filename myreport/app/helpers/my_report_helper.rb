module MyReportHelper
  def reminder_registered(email)
    Report.check_remind_registered email
  end
end
