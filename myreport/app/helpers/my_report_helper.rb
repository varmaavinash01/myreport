module MyReportHelper
  def get_issue_titles(issues)
    ret = ""
    issues.each do |issue|
      ret += issue.summary + "\n" + "https://rakuten.atlassian.net/browse/" + issue.key + "\n\n" 
    end
    ret
  end
  
  def issue_type_icon_url(issue_properties)
    issue_properties.to_json
  end
  def reminder_registered(email)
    Report.check_remind_registered email
  end
end
