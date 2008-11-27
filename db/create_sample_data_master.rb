test = Master::Hospital.create(:name => 'Harbor-UCLA',
                             :code => 'harbor', :key => 'harbor')
test.hosts.create(:host => 'localhost')
test.hosts.create(:host => 'harbor.nedocsonline.org')
test.hosts.create(:host => 'dev.harbor.nedocsonline.org')

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
