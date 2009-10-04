#!/usr/bin/env ruby

# Script that will correct all NEDOCS score
# to use the latest algorithm, warning running
# this script will change historial NEDOCS data!!

ENV['RAILS_ENV'] ||= 'development'
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')

hospital = ARGV.shift || ENV['RAILS_HOSPITAL']

unless hospital
  print "\nusage:\n"
  print "random_data <hospital code>\n\n"
else
  ActiveRecord::Base.connect_to_hospital(hospital)

start_time = Time.now()-1.year
end_time = Time.now()
user = User.find(:first)

(start_time..end_time).step(3600*24) do |hour|
  n = Nedoc.new
  n.user_id = user.id
  n.created_at = hour
  n.number_ed_beds = rand(35)
  n.number_hospital_beds = rand(400)
  n.total_patients_ed = rand(30)
  n.total_respirators = rand(2)
  n.longest_admit = rand(18)
  n.total_admits = rand(20)
  n.last_patient_wait = rand(12)
  n.calc_score
  
  print "#{hour}: #{score} "
  
end