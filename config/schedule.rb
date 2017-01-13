# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
env :PATH, ENV['PATH']
# Example:
#

set :output, "#{File.expand_path(File.dirname(__FILE__))}/cron_log.log"

every 2.hours do

  # runner "FileRollUtils.exec_roll(\"\/alidata1\/www\/elephant\/shared\/log\/\",\"production.log\",10,1073741824)"

  runner "FileRollUtils.exec_demo(\"Hello World!!\")"
end

# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever



