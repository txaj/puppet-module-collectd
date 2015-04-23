# See http://collectd.org/documentation/manpages/collectd.conf.5.shtml#plugin_python
class collectd::plugin::python (
  $modulepath = '/usr/lib/collectd/python',
  $ensure     = present,
  $modules    = {},
  $order      = '10',
  $interval   = undef,
) {
  include collectd::params

  validate_hash($modules)

  $conf_dir = $collectd::params::plugin_conf_dir

  collectd::plugin {'python':
    ensure   => $ensure,
    interval => $interval,
    order    => $order,
  }

  # should be loaded after global plugin configuration
  $python_conf = "${collectd::params::plugin_conf_dir}/11-python-config.conf"

  concat{ $python_conf:
    ensure         => $ensure,
    mode           => '0640',
    owner          => 'root',
    group          => $collectd::params::root_group,
    notify         => Service['collectd'],
    ensure_newline => true,
  }

  concat::fragment{'collectd_plugin_python_conf_header':
    order   => '00',
    content => template('collectd/plugin/python/header.conf.erb'),
    target  => $python_conf,
  }

  concat::fragment{'collectd_plugin_python_conf_footer':
    order   => '99',
    content => '</Plugin>',
    target  => $python_conf,
  }

  $defaults = {
    'modulepath'  => $modulepath,
    'ensure'      => $ensure,
    'python_conf' => $python_conf,
  }
  create_resources(collectd::plugin::python::script, $modules, $defaults)
}
