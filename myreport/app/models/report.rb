class Report
  class << self
    def check_remind_registered(email)
      key  = DateTime.now.strftime("%A") + "-RemainderMailList-MyReport"
      list = REDIS.lrange(key, 0, -1)
      list.include?(email)
    end
  end
end