#
# This script should set up all the data necessary to get someone started on
# Backdrop.
#

ActiveRecord::Base.connect_to_hospital

User.create :username => 'admin', :password => 'admin',
            :first_name => 'Studio', :last_name => 'Administrator',
            :title => 'Studio Owner',
            :email_address => 'rctest@reflectconnect.com'

# This will be different once we get some resellers on board
Setting.create  :name => 'feedback_recipients',
                :value => 'sabin@reflectconnect.com,aaron@reflectconnect.com'
Setting.create  :name => 'image_archive_location',
                :value => '/Users/Shared/BackdropArchive/TestStudio/'

ClientGroup.create :name => 'Sample Group'
ProductGroup.create :name => 'Uncategorized'
OrderStatus.create :name => 'Order Accepted', :status_type => 0
TaxLocation.create :name => "Tax Exempt", :rate => 0.0

# make a default set of appt statuses
%w{ booked completed no-show rescheduled }.each do |name|
  AppointmentStatus.create(:name => name)
end
