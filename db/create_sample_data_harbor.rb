ActiveRecord::Base.connect_to_hospital

test = User.create(
        :username => 'nedocs1',
        :password => 'alpha10',
        :first_name => 'nedocs1',
        :last_name => 'nedocs1')
        
Setting.create  :name => 'public_display_score',
                :value => 'true'
Setting.create  :name => 'number_of_hospital_beds',
                :value => '350'        