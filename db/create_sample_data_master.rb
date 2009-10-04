test = Master::Hospital.create(:name => 'Hospital Name',
                             :code => 'demo', :key => 'demo')
test.hosts.create(:host => 'demo')
test.hosts.create(:host => 'demo.nedocsonline.org')

# demo = Master::Hospital.create(:name => 'Demo Studio',
#                              :code => 'demo', :key => 'demo')
# demo.hosts.create(:host => 'demo.backdroponline.com')

# Master::Setting.create(:name => 'permission_set', :value => [
#  { :name => 'Manage Users',
#    :code => 'can_manage_users',
#    :description => 'Full control over employee access.' },
#  { :name => 'Manage Clients',
#    :code => 'can_manage_clients',
#    :description => 'Full control over clients.' }
# ])
