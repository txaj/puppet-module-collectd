require 'spec_helper'

describe 'collectd::plugin::python', :type => :class do

  context ':ensure => present' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :concat_basedir => tmpfilename('collectd-python'),
        :path           => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    end
    let (:config_filename) { '/etc/collectd/conf.d/10-python.conf' }

    let (:title) {'python'}
    let (:concat_fragment_name) { 'collectd_plugin_python' }
    let :params do
      {
        :modulepath    => '/usr/lib/collectd',
        :modules       => {
          'elasticsearch' => {
            :script_source => 'puppet:///modules/myorg/elasticsearch_collectd_python.py',
            :config        => {'Cluster' => 'elasticsearch'}
          }
        }
      }
    end

    it 'provides a python concat fragment' do
      should contain_concat__fragment(concat_fragment_name).with({
        :target => config_filename,
        :order => '10',
      })
    end

   # it 'Will create /etc/collectd/conf.d/10-python.conf' do
   #   should contain_concat__fragment('collectd_plugin_python_conf_elasticsearch').with({
   #     :ensure  => 'present',
   #     :path    => '/etc/collectd/conf.d/10-elasticsearch.conf',
   #     :content => "<LoadPlugin \"python\">\n    Globals true\n</LoadPlugin>\n\n<Plugin \"python\">\n    ModulePath \"/usr/lib/collectd\"\n\n    Import \"elasticsearch\"\n\n    <Module \"elasticsearch\">\n        Verbose false\n\t\tCluster \"elasticsearch\"\n    </Module>\n</Plugin>\n",
   #   })
   # end
   # it 'Will create /usr/lib/collectd/elasticsearch.py' do
   #   should contain_file('elasticsearch.script').with({
   #     :ensure  => 'present',
   #     :path    => '/usr/lib/collectd/elasticsearch.py',
   #     #:content => "<Plugin network>\n  <Server \"node1\" \"1234\">\n    SecurityLevel \"Encrypt\"\n    Username \"foo\"\n    Password \"bar\"\n    Interface \"eth0\"\n\n  </Server>\n</Plugin>\n",
   #   })
   # end
  end

  context ':ensure => absent' do
    let :facts do
      {
        :osfamily         => 'Debian'
      }
    end
    let (:title) {'elasticsearch'}
    let :params do
      {
        :ensure        => 'absent',
        :modulepath    => '/usr/lib/collectd',
        :module        => 'elasticsearch',
        :script_source => 'puppet:///modules/myorg/elasticsearch_collectd_python.py',
        :config        => {'Cluster' => 'elasticsearch'},
      }
    end
    it 'Will not create /etc/collectd/conf.d/10-elasticsearch.conf' do
      should contain_file('elasticsearch.load').with({
        :ensure => 'absent',
        :path    => '/etc/collectd/conf.d/10-elasticsearch.conf',
      })
    end
    it 'Will not create /usr/lib/collectd/elasticsearch.py' do
      should contain_file('elasticsearch.script').with({
        :ensure => 'absent',
        :path    => '/usr/lib/collectd/elasticsearch.py',
      })
    end
  end

end
