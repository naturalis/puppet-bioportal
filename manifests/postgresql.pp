# == Class: bioportal::postgresql
#
# postgresql.pp for bioportal puppet module
#
# Author : Hugo van Duijn
#
class bioportal::postgresql (
  $backup,
  $backuppostgresqlhour,
  $backuppostgresqlminute,
  $backupdir,
  $postgresqlDbName,
  $postgresqlUser,
  $postgresqlPassword,
  $postgresqlBackupUser,
  $postgresqlBackupPassword,
) {

  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '9.1',
  }->
  class {'postgresql::server':}

  package {
    "postgis":
        ensure    => latest;
    "postgresql-9.1-postgis":
        ensure    => latest;
    "proj":
        ensure => latest;
    "libgeos-3.2.2":
        ensure => latest;
    "gdal-bin":
        ensure => latest;
    }
 
  file { "/tmp/create_template_postgis.sh":
    ensure => "present",
    source => "puppet:///modules/bioportal/create_template_postgis.sh",
  }

  exec {"/bin/bash /tmp/create_template_postgis.sh":
    user => "postgres",
    unless => "/usr/bin/psql -l | grep 'template_postgis  *|'",
    require => [Package['postgis'],File['/tmp/create_template_postgis.sh']],
  }->
  postgresql::server::db { $postgresqlDbName:
    user     => $postgresqlUser,
    password => postgresql_password($postgresqlUser, $postgresqlPassword),
    template => "template_postgis",
  }

}
