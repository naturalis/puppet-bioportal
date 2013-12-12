# == Class: bioportal
#
# init.pp for bioportal puppet module
#
# Author : Hugo van Duijn
#
class bioportal (
  $backup              = false,
  $backuphour          = 5,
  $backupminute        = 5,
  $backupmysqlhour     = 4,
  $backupmysqlminute   = 4,
  $version             = 'latest',
  $backupdir           = '/tmp/backups',
  $bucket              = 'linuxbackups',
  $bucketfolder        = 'bioportal',
  $dest_id             = undef,
  $dest_key            = undef,
  $cloud               = 's3',
  $pubkey_id           = undef,
  $full_if_older_than  = 30,
  $remove_older_than   = 31,
  $coderepo            = 'svn://repoaddress/trunk',
  $repotype            = 'svn',
  $repoenabled         = false,
  $coderoot            = '/var/www/bioportal',
  $webdirs             = ['/var/www/bioportal'],
  $rwwebdirs           = ['/var/www/bioportal/upload',
                          '/var/www/bioportal/cache'],
  $apachegroup         = 'www-data',
  $php_memory_limit    = '256M',
  $php_date_timezone   = 'Europe/Amsterdam',
  $php_upload_max_filesize = '32M',
  $userDbName          = 'nlbif_site',
  $mysqlUser           = 'bioportal_user',
  $mysqlPassword       = 'default mysqlpassword',
  $mysqlRootPassword   = 'defaultrootpassword',
  $mysqlBackupUser     = 'backupuser',
  $mysqlBackupPassword = 'defaultbackuppassword',
  $postgresqlDbName    = 'bioportal',
  $postgresqlUser      = 'bioportal_user',
  $postgresqlPassword  = 'defaultpsqlpwd',
  $postgresqlBackupUser     = 'backupuser',
  $postgresqlBackupPassword = 'defaultbackuppassword',
  $appVersion          = '1.0.0',
  $instances           = {'bioportal.naturalis.nl' => { 
                           'serveraliases'   => '*.naturalis.nl',
                           'aliases'         => [{ 'alias' => '/test', 'path' => '/var/www/bioportal/test' }],
                           'docroot'         => '/var/www/bioportal',
                           'directories'     => [{ 'path' => '/var/www/bioportal', 'options' => '-Indexes FollowSymLinks MultiViews', 'AllowOverride' => 'none' }],
                           'port'            => 80,
                           'serveradmin'     => 'webmaster@bioportal.naturalis.nl',
                           'priority'        => 10,
                          },
                          },
) {

  # include concat and mysql 
  include concat::setup

  class { 'bioportal::mysql':
    backup              => $backup,
    backupmysqlhour     => $backupmysqlhour,
    backupmysqlminute   => $backupmysqlminute,
    restore             => $restore,
    backupdir           => $backupdir,
    userDbName          => $userDbName,
    mysqlUser           => $mysqlUser,
    mysqlPassword       => $mysqlPassword,
    mysqlRootPassword   => $mysqlRootPassword,
    mysqlBackupUser     => $mysqlBackupUser,
    mysqlBackupPassword => $mysqlBackupPassword,
  }

  class { 'bioportal::postgresql':
    backup                   => $backup,
    backuppostgresqlhour     => $backuppostgresqlhour,
    backuppostgresqlminute   => $backuppostgresqlminute,
    backupdir                => $backupdir,
    postgresqlDbName         => $postgresqlDbName,
    postgresqlUser           => $postgresqlUser,
    postgresqlPassword       => $postgresqlPassword,
    postgresqlBackupUser     => $postgresqlBackupUser,
    postgresqlBackupPassword => $postgresqlBackupPassword,
  }

  # install apache
  class { 'apache':
    default_mods => true,
    mpm_module => 'prefork',
  }
  include apache::mod::php


  # Create all virtual hosts from hiera
  class { 'bioportal::instances': 
    instances => $instances,
  }

  # Add hostname to /etc/hosts, svn checkout requires a resolvable hostname
  host { 'localhost':
    ip => '127.0.0.1',
    host_aliases => [ $hostname ],
  }

  # Get data from SVN repo
  if $repoenabled == true { 
    package { 'subversion':
      ensure    => installed,
    }
    vcsrepo { $coderoot:
      ensure    => latest,
      provider  => $repotype,
      source    => $coderepo,
      require   => [ Package['subversion'],Host['localhost'] ],
    }
  }

  # create application specific directories
  file { $webdirs:
    ensure      => 'directory',
    mode        => '0755',
    if $repoenabled == true {
      require   => Vcsrepo[$coderoot],
    }
  }

  file { $rwwebdirs:
    ensure 	=> 'directory',
    mode   	=> '0660',
    owner	=> root,
    group	=> $apachegroup,
    recurse     => true,
    require 	=> File[$webdirs],
  }

  # create backup job
  if $backup == true {
    class { 'bioportal::backup':
      backuphour         => $backuphour,
      backupminute       => $backupminute,
      backupdir          => $backupdir,
      bucket             => $bucket,
      folder             => $bucketfolder,
      dest_id            => $dest_id,
      dest_key           => $dest_key,
      cloud              => $cloud,
      pubkey_id          => $pubkey_id,
      full_if_older_than => $full_if_older_than,
      remove_older_than  => $remove_older_than,
    }
  }

  # install php modules and configure php parameters
  class { 'bioportal::php':
    memory_limit        => $php_memory_limit,
    date_timezone       => $php_date_timezone,
    upload_max_filesize => $php_upload_max_filesize,
  }

# create config files based on templates, not used at this moment. Usefull when using SVN repo
#  file { "${coderoot}/configuration/admin/configuration.php":
#    content       => template('bioportal/adminconfig.erb'),
#    mode          => '0640',
#    owner         => root,
#    group         => $apachegroup,
#    require       => Vcsrepo[$coderoot],
#  }
#  file { "${coderoot}/configuration/app/configuration.php":
#    content       => template('bioportal/appconfig.erb'),
#    mode          => '0640',
#    owner         => root,
#    group         => $apachegroup,
#    require       => Vcsrepo[$coderoot],
#  }

}
