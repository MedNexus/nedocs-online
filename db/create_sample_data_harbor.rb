ActiveRecord::Base.connect_to_hospital

test = User.create(
        :username => 'nedocs1',
        :password => 'alpha10',
        :first_name => 'nedocs1',
        :last_name => 'nedocs1')

test = User.create(
        :username => 'nedocs2',
        :password => 'bravo11',
        :first_name => 'nedocs2',
        :last_name => 'nedocs2')

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
                        
Setting.create  :name => 'public_display_score',
                :value => 'true'
Setting.create  :name => 'number_of_hospital_beds',
                :value => '350'        