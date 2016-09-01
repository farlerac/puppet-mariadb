# mysql.pp
# Manage the puppetlabs mysql module.
#

class mariadb::cluster::mysql {

  validate_bool($mariadb::cluster::auth_pam)
  validate_string($mariadb::cluster::auth_pam_plugin)

  validate_string($mariadb::cluster::root_password)

  if $mariadb::cluster::auth_pam {
    $auth_pam_options = {'mysqld' => {'plugin-load' => $mariadb::cluster::auth_pam_plugin}}
  } else {
    $auth_pam_options = {}
  }

  if $mariadb::cluster::wsrep_sst_method in ['xtrabackup', 'xtrabackup-v2'] {
    package { 'percona-xtrabackup':
      ensure => installed,
      before => Class['::mysql::server'],
    }
  }

  class { '::mysql::server':
    config_file             => $mariadb::cluster::config_file,
    includedir              => $mariadb::cluster::includedir,
    override_options        => mysql_deepmerge($auth_pam_options, $mariadb::cluster::options),
    package_ensure          => installed,
    package_name            => 'MariaDB-Galera-server', # ['MariaDB-Galera-server', 'galera'],
    remove_default_accounts => true,
    restart                 => $mariadb::cluster::restart,
    root_password           => $mariadb::cluster::root_password,
    service_enabled         => $mariadb::cluster::service_enabled,
    service_manage          => $mariadb::cluster::service_manage,
    service_name            => 'mysql',
  }

  anchor { 'mariadb::cluster::mysql::start': } ->
  Class['::mysql::server'] ->
  anchor { 'mariadb::cluster::mysql::end': }
}