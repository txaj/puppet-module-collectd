#
define collectd::plugin::python::module (
  $config,
  $script_source = undef,
  $modulepath    = $collectd::plugin::python::modulepath,
  $module        = $title,
  $ensure        = 'present',
  $order         = '50',
  $python_conf   = "${collectd::params::plugin_conf_dir}/11-python-config.conf",
){
  include collectd::params
  include collectd::plugin::python

  validate_hash($config)

  if $script_source {
    file { "${module}.script":
      ensure => $ensure,
      path   => "${modulepath}/${module}.py",
      owner  => 'root',
      group  => $collectd::params::root_group,
      mode   => '0640',
      source => $script_source,
      notify => Service['collectd'],
    }
  }

  concat::fragment{"collectd_plugin_python_conf_${module}":
    ensure  => $ensure,
    order   => $order,
    target  => $python_conf,
    content => template('collectd/plugin/python/module.conf.erb'),
  }
}
