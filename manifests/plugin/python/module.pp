# Single module definition
define collectd::plugin::python::module (
  $config,
  $script_source = undef,
  $module        = $title,
  $ensure        = 'present',
){
  include collectd::params
  include collectd::plugin::python

  validate_hash($config)

  if $script_source {
    file { "${module}.script":
      ensure => $ensure,
      # $modulepath is shared for all modules, can't be changed in a module
      path   => "${collectd::plugin::python::modulepath}/${module}.py",
      owner  => 'root',
      group  => $collectd::params::root_group,
      mode   => '0640',
      source => $script_source,
      notify => Service['collectd'],
    }
  }

  concat::fragment{"collectd_plugin_python_conf_${module}":
    ensure  => $ensure,
    order   => '50', # somewhere between header and footer
    target  => $collectd::plugin::python::python_conf,
    content => template('collectd/plugin/python/module.conf.erb'),
  }
}
