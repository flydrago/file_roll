# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
require File.expand_path(File.dirname(__FILE__) + '/file_roll_utils')

# Example:
#

set :output, "#{File.expand_path(File.dirname(__FILE__))}/cron_log.log"

every 2.hours do

  command "echo '清理elephant日志'"
  FileRollUtils.exec_roll("/Users/jyd-pc005/logs","tomcat8916_bak",10,30)
end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever



