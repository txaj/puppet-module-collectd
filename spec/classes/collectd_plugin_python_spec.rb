require 'spec_helper'

describe 'collectd::plugin::python', :type => :class do

  let :facts do
    {
      :osfamily         => 'Debian',
      :concat_basedir   => tmpfilename('collectd-python'),
      :id               => 'root',
      :kernel           => 'Linux',
      :path             => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      :collectd_version => '5.0'
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

      it 'Will create /etc/collectd.d/conf.d/python-config.conf' do
        should contain_concat__fragment('collectd_plugin_python_conf_header').with({
          :content => /<Plugin "python">/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
          :order   => '00'
        })
      end

      it 'set default Python module path' do
        should contain_concat__fragment('collectd_plugin_python_conf_header').with({
          :content => /ModulePath "\/usr\/lib\/collectd\/python"/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
        })
      end

      it 'Will create /etc/collectd.d/conf.d/python-config.conf' do
        should contain_concat__fragment('collectd_plugin_python_conf_footer').with({
          :content => /<\/Plugin>/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
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
            },
            'foo' => {
              'config' => {'Verbose' => true, 'Bar' => 'bar' }
            }
          }
        }
      end

      it 'imports elasticsearch module' do
        should contain_concat__fragment('collectd_plugin_python_conf_elasticsearch').with({
          :content => /Import "elasticsearch"/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
        })
      end

      it 'includes elasticsearch module configuration' do
        should contain_concat__fragment('collectd_plugin_python_conf_elasticsearch').with({
          :content => /<Module "elasticsearch">/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
        })
      end

      it 'includes elasticsearch Cluster name' do
        should contain_concat__fragment('collectd_plugin_python_conf_elasticsearch').with({
          :content => /Cluster "ES-clust"/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
        })
      end

      it 'created collectd plugin file' do
        should contain_file('elasticsearch.script').with({
          :ensure  => 'present',
          :path    => '/usr/lib/collectd/python/elasticsearch.py',
        })
      end

      # test foo module
      it 'imports foo module' do
        should contain_concat__fragment('collectd_plugin_python_conf_foo').with({
          :content => /Import "foo"/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
        })
      end

      it 'includes foo module configuration' do
        should contain_concat__fragment('collectd_plugin_python_conf_foo').with({
          :content => /<Module "foo">/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
        })
        should contain_concat__fragment('collectd_plugin_python_conf_foo').with({
          :content => /Verbose "true"/,
        })
        should contain_concat__fragment('collectd_plugin_python_conf_foo').with({
          :content => /Bar "bar"/,
        })
      end
    end

    context 'allow changing module path' do
      let :params do
        {
          :modulepath => '/var/lib/collectd/python',
          :modules    => {
            'elasticsearch' => {
              'script_source' => 'puppet:///modules/myorg/elasticsearch_collectd_python.py',
              'config'        => {'Cluster' => 'ES-clust'}
            }
          }
        }
      end

      it 'set default Python module path' do
        should contain_concat__fragment('collectd_plugin_python_conf_header').with({
          :content => /ModulePath "\/var\/lib\/collectd\/python"/,
          :target  => '/etc/collectd/conf.d/python-config.conf',
        })
      end

      it 'created collectd plugin file' do
        should contain_file('elasticsearch.script').with({
          :ensure  => 'present',
          :path    => '/var/lib/collectd/python/elasticsearch.py',
        })
      end
    end
  end

  context 'change globals parameter' do
    let :params do
      {
        :globals => true
      }
    end

    it 'will change $globals settings' do
      should contain_file('python.load').with({
        :ensure  => 'present',
        :path    => '/etc/collectd/conf.d/10-python.conf',
        :content => /Globals true/,
      })
    end
  end

  context 'allow passing shared options for all modules' do
    let :params do
      {
        :options => { 'LogTraces' => true, 'Interactive' => false}
      }
    end

    it 'sets options' do
      should contain_concat__fragment('collectd_plugin_python_conf_header').with({
        :content => /LogTraces true/,
        :target  => '/etc/collectd/conf.d/python-config.conf',
      })

      should contain_concat__fragment('collectd_plugin_python_conf_header').with({
        :content => /Interactive false/,
      })
    end
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
        :target  => '/etc/collectd/conf.d/python-config.conf',
        :order   => '00'
      })
    end
  end

end
