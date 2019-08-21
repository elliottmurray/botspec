
require "rspec/core"
require "rspec/core/formatters"

class DavidFormatter
  RSpec::Core::Formatters.register self, :dump_summary, :close, :example_failed, :dump_failures, :message, :stop, :start_dump, :example_group_finished

  def initialize output
    @output = output
  end

  def dump_summary notification # SummaryNotification
    @output << "\n\nDDDDDDDDDDD inished in #{notification.duration}."
  end

  def close notification # NullNotification
    @output << "notification end: " + notification.inspect
  end

  def example_failed notification
    puts "\n\n got example_failed failed test: " + notification.inspect
  end

  def dump_failures notification
    #puts "\n\n failures dumped: " + notification.inspect
    puts "\n\n failures: " + notification.examples.inspect
    puts "\n\n failures: " + notification.examples[0].inspect
    puts "\n\n failures exception: " + notification.examples[0].exception.inspect
    puts "\n\n failures exception: " + notification.examples[1].exception.inspect
  end

  def message notification
   puts  "\n\n MESSAGE???: " + notification.inspect
  end

  def stop notification
   #byebug
   #puts "\n\n called STOPP!: " + notification.inspect
  end

  def start_dump notification
    #puts "\n\n START DUMP: " + notification.inspect
  end

  def example_group_finished notification
    #puts "\n\n EG Finished: " + notification.inspect
  end

  def example_finished notification
    #puts "\n\n example finished: " + notification.inspect
  end  

end

