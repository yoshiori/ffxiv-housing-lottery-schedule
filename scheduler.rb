require "date"
require "icalendar"

ICAL_FILE = File.join(__dir__, "schedule.ics")

Event = Struct.new(:name, :days)
LOTTERY_PERIOD = Event.new("抽選期間", 5)
RESULT_ANNOUNCEMENT = Event.new("結果発表期間", 4)

cal = Icalendar::Calendar.parse(File.read(ICAL_FILE)).first
unless cal.events[1].dtend < Date.today # latest result announcement date
  puts "Latest Result announement end day: #{cal.events[1].dtend}, today: #{Date.today}"
  exit
end

start = cal.events.last.dtend
[LOTTERY_PERIOD, RESULT_ANNOUNCEMENT].each do |event|
  cal.event do |e|
    e.dtstart     = Icalendar::Values::Date.new(start)
    e.dtend       = Icalendar::Values::Date.new(start + event.days)
    e.summary     = event.name
  end
  start += event.days
end
cal.events.shift(2)
File.write(ICAL_FILE, cal.to_ical)
