require 'spec_helper'

describe 'collectd::plugin::python', :type => :class do

  let :facts do
    {
      :osfamily       => 'Debian',
      :concat_basedir => tmpfilename('collectd-python'),
      :path           => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end

  context ':ensure => present' do
    context ':ensure => present and default parameters' do
      it 'Will create /etc/collectd/conf.d/10-python.conf to load the plugin' do
        should contain_file('python.load').with({
          :ensure  => 'present',
          :path    => '/etc/collectd/conf.d/10-python.conf',
          :content => /LoadPlugin python/,
        })
      end

      it 'Will create /etc/collectd.d/conf.d/11-python.conf' do
        should contain_concat__fragment('collectd_plugin_python_conf_header').with({
          :content => /<Plugin "python">/,
          :target  => '/etc/collectd/conf.d/11-python-config.conf',
          :order   => '00'
        })
      end

      it 'set default Python module path' do
        should contain_concat__fragment('collectd_plugin_python_conf_header').with({
          :content => /ModulePath "\/usr\/lib\/collectd\/python"/,
          :target  => '/etc/collectd/conf.d/11-python-config.conf',
        })
      end

      it 'Will create /etc/collectd.d/conf.d/11-python.conf' do
        should contain_concat__fragment('collectd_plugin_python_conf_footer').with({
          :content => /<\/Plugin>/,
          :target  => '/etc/collectd/conf.d/11-python-config.conf',
          :order   => '99'
        })
      end
    end

    context ':ensure => present and configure elasticsearch module' do
      let :params do
        {
          :modules => {
            'elasticsearch' => {
              'script_source' => 'puppet:///modules/myorg/elasticsearch_collectd_python.py',
              'config'        => {'Cluster' => 'ES-clust'}
            }
          }
        }
      end

      it 'imports elasticsearch module' do
        should contain_concat__fragment('collectd_plugin_python_conf_elasticsearch').with({
          :content => /Import "elasticsearch"/,
          :target  => '/etc/collectd/conf.d/11-python-config.conf',
        })
      end

      it 'includes elasticsearch module configuration' do
        should contain_concat__fragment('collectd_plugin_python_conf_elasticsearch').with({
          :content => /<Module "elasticsearch">/,
          :target  => '/etc/collectd/conf.d/11-python-config.conf',
        })
      end

      it 'includes elasticsearch Cluster name' do
        should contain_concat__fragment('collectd_plugin_python_conf_elasticsearch').with({
          :content => /Cluster "ES-clust"/,
          :target  => '/etc/collectd/conf.d/11-python-config.conf',
        })
      end
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
    let (:title) {'elasticsearch'}
    let :params do
      {
        :ensure        => 'absent',
        :modules => {
          'elasticsearch' => {
            'script_source' => 'puppet:///modules/myorg/elasticsearch_collectd_python.py',
            'config'        => {'Cluster' => 'ES-clust'}
          }
        }
      }
    end

    it 'will remove /etc/collectd/conf.d/10-python.conf' do
      should contain_file('python.load').with({
        :ensure  => 'absent',
        :path    => '/etc/collectd/conf.d/10-python.conf',
        :content => /LoadPlugin python/,
      })
    end

    it 'won\'t create /etc/collectd.d/conf.d/11-python.conf (no modules defined)' do
      should_not contain_concat__fragment('collectd_plugin_python_conf_header').with({
        :ensure  => 'absent',
        :target  => '/etc/collectd/conf.d/11-python-config.conf',
        :order   => '00'
      })
    end
  end

end
