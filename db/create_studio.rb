#
# This script should set up all the data necessary to get someone started on
# Backdrop.
#

ActiveRecord::Base.connect_to_hospital

User.create :username => 'nedocs1', :password => 'alpha10',
            :first_name => 'nedocs1', :last_name => 'nedocs1'


# This will be different once we get some resellers on board
Setting.create  :name => 'feedback_recipients',
                :value => 'sabin@reflectconnect.com,aaron@reflectconnect.com'
Setting.create  :name => 'public_display_score',
                :value => 'true'
Setting.create  :name => 'number_of_hospital_beds',
                :value => '350'
                

