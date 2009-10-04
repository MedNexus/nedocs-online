test = User.create(
        :username => 'demo',
        :password => 'demo',
        :first_name => 'demo',
        :last_name => 'user',
        :send_notifications => 1,
        :notify_threshold => 0,
        :notify_address => "demo@nedocsonline.org" )
        
Setting.create  :name => 'public_display_score',
                :value => 'true'
Setting.create  :name => 'number_of_hospital_beds',
                :value => '400'