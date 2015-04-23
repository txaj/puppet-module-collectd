#
define collectd::plugin::python::script (
  $config,
  $script_source = undef,
  $modulepath    = $collectd::plugin::python::modulepath,
  $module        = $title,
  $ensure        = 'present',
  $order         = '50',
){
  include collectd::params
  include collectd::plugin::python

  validate_hash($config)

  if $script_source {
    file { "${module}.script":
      ensure  => $ensure,
      path    => "${modulepath}/${module}.py",
      owner   => 'root',
      group   => $collectd::params::root_group,
      mode    => '0640',
      source  => $script_source,
      notify  => Service['collectd'],
    }
  }

  concat::fragment{"collectd_plugin_python_conf_${module}":
    ensure  => $ensure,
    order   => $order,
    target  => "${collectd::params::plugin_conf_dir}/11-python-config.conf",
    content => template('collectd/plugin/python/script.conf.erb'),
  }
}
