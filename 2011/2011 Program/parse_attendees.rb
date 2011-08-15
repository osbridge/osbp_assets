require 'rubygems'
require 'fastercsv'

ATTENDEE_CSV = 'Attendees.csv'
BADGE_CSV_OUTPUT = 'Badges.csv'

AttendeeStruct = Struct.new(:first_name, 
                            :last_name, 
                            :company,
                            :ticket_type, 
                            :discount_code, 
                            :t_shirt_size,
                            :age,
                            :gender, 
                            :food_preference,
                            :years_in_open_source,
                            :attended_2010,
                            :evening_reception,
                            :other_requests)

class Attendee < AttendeeStruct
  def initialize(row)
    (self.last_name, self.first_name, self.ticket_type, self.discount_code, 
     self.t_shirt_size, self.age, self.gender, 
     self.food_preference, self.years_in_open_source, self.attended_2010, 
     self.evening_reception, self.other_requests, self.company) = *row
     
     self.discount_code = "" unless self.discount_code
  end
  
  def speaker?;   self.discount_code.include?('speaker_'); end
  def volunteer?; self.discount_code.include?('volunteer_'); end
  def sponsor?;   self.discount_code.include?('sponsor_'); end
  def media?;     self.discount_code.include?('media_'); end
  
  def badge_type
    [ speaker?    && "Speaker",
      volunteer?  && "Volunteer",
      sponsor?    && "Sponsor",
      media?      && "Media"
    ].select{|t| t}.join(' / ')
  end
  
  def name
    [self.first_name, self.last_name].compact.join("___")
  end
end

rows = FasterCSV.read(ATTENDEE_CSV)
rows.shift

attendees = rows.map{|row| Attendee.new(row) }

File.delete(BADGE_CSV_OUTPUT) if File.exists?(BADGE_CSV_OUTPUT)

FasterCSV.open(BADGE_CSV_OUTPUT, "w") do |csv|
  csv << ['First Name', 'Last Name', 'Company', 'Badge Type']
  attendees.sort{|a,b| a.badge_type <=> b.badge_type }.each do |attendee|
    csv << [attendee.first_name, attendee.last_name, attendee.company, attendee.badge_type]
  end
end
