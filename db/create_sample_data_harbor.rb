ActiveRecord::Base.connect_to_hospital

test = User.create(
        :username => 'nedocs1',
        :password => 'alpha10',
        :first_name => 'nedocs1',
        :last_name => 'nedocs1',
        :notify => 1,
        :notify_threshold => 100,
        :notify_address => "sabin+nedocs@sabindang.com" )

test = User.create(
        :username => 'nedocs2',
        :password => 'bravo11',
        :first_name => 'nedocs2',
        :last_name => 'nedocs2',
        :send_notification => 1,
        :notify_threshold => 180,
        :notify_address => "sabin@ucla.edu")

test = User.create(
        :username => 'nedocs3',
        :password => 'charlie12',
        :first_name => 'nedocs3',
        :last_name => 'nedocs3')
        
test = User.create(
        :username => 'nedocs4',
        :password => 'delta13',
        :first_name => 'nedocs4',
        :last_name => 'nedocs4')

test = User.create(
        :username => 'nedocs5',
        :password => 'echo14',
        :first_name => 'nedocs5',
        :last_name => 'nedocs5')
        
test = User.create(
        :username => 'nedocs6',
        :password => 'foxtrot15',
        :first_name => 'nedocs6',
        :last_name => 'nedocs6')

test = User.create(
        :username => 'nedocs7',
        :password => 'golf16',
        :first_name => 'nedocs7',
        :last_name => 'nedocs7')
        
test = User.create(
        :username => 'nedocs8',
        :password => 'hotel17',
        :first_name => 'nedocs8',
        :last_name => 'nedocs8')
        
test = User.create(
        :username => 'nedocs9',
        :password => 'india18',
        :first_name => 'nedocs9',
        :last_name => 'nedocs9')
        
test = User.create(
        :username => 'nedocs10',
        :password => 'juliet19',
        :first_name => 'nedocs10',
        :last_name => 'nedocs10')
        
test = User.create(
        :username => 'roger',
        :password => 'rlewis443',
        :first_name => "Roger",
        :last_name => "Lewis",
        :send_notifications => 0,
        :is_superuser => 1,
        :notify_address => "roger@emedharbor.edu",
        :notify_threshold => 200 )


test = User.create(
        :username => 'cstevens',
        :password => 'cstevens251',
        :first_name => "Carl",
        :last_name => "Stevens",
        :send_notifications => 0,
        :is_superuser => 1,
        :notify_address => "cstevens@emedharbor.edu",
        :notify_threshold => 200 )                 

test = User.create(
        :username => 'ross',
        :password => 'rdonaldson913',
        :first_name => "Ross",
        :last_name => "Donaldson",
        :send_notifications => 0,
        :is_superuser => 1,
        :notify_address => "ross@rossdonaldson.com",
        :notify_threshold => 200 )

test = User.create(
        :username => 'peterson',
        :password => 'mpeterson889',
        :first_name => "Mike",
        :last_name => "Peterson",
        :send_notifications => 0,
        :is_superuser => 1,
        :notify_address => "peterson@emedharbor.edu",
        :notify_threshold => 200 )               

test = User.create(
        :username => 'hock',
        :password => 'bhockberger537',
        :first_name => "Bob",
        :last_name => "Hockberger",
        :send_notifications => 0,
        :is_superuser => 1,
        :notify_address => "hock@emedharbor.edu",
        :notify_threshold => 200 )
        
test = User.create(
        :username => 'sabin',
        :password => 'fdxfdx1',
        :first_name => "Sabin",
        :last_name => "Dang",
        :send_notifications => 1,
        :is_superuser => 1,
        :notify_address => "sabin+nedocs+harbor@sabindang.com",
        :notify_threshold => 1 )
        
test = User.create(:username => 'sblack', :password => 'sblack043', :first_name => "Susan", :last_name => "Black", :send_notifications => 1, :is_superuser => 0, :notify_address => "sblack@dhs.lacounty.gov", :notify_threshold => 180)

test = User.create(:username => 'lfields', :password => 'lfields224', :first_name => "Lori", :last_name => "Fields", :send_notifications => 1, :is_superuser => 0, :notify_address => "lfields@dhs.co.la.ca.us", :notify_threshold => 180)
        
        
Setting.create  :name => 'public_display_score',
                :value => 'true'
Setting.create  :name => 'number_of_hospital_beds',
                :value => '350'        