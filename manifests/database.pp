# == Class: bioportal::database
#
# database.pp for bioportal puppet module
#
# Author : Hugo van Duijn
#
class bioportal::database (
  $backup,
  $backupmysqlhour,
  $backupmysqlminute,
  $restore,
  $backupdir,
  $userDbName,
  $mysqlUser,
  $mysqlPassword,
  $mysqlRootPassword,
  $mysqlBackupUser,
  $mysqlBackupPassword,
) {

  class { 'mysql::bindings':
    php_enable       => true
  }
  class { 'mysql::server':
    root_password    => $mysqlRootPassword
  }

  mysql::db { $userDbName:
    user           => $mysqlUser,
    password       => $mysqlPassword,
    host           => 'localhost',
    grant          => ['ALL'],
  }

  mysql_grant { "${mysqlbackupuser}@localhost/${userDbName}.*":
    ensure         => 'present',
    user           => "${mysqlBackupUser}@localhost",
    options        => ['GRANT'],
    privileges     => ['ALL'],
    table          => '*.*',
  }
  # create mysql backup and restore scripts
  if ($backup == true) or ($restore == true) {
    class { 'mysql::server::backup':
      backupuser      => $mysqlBackupUser,
      backuppassword  => $mysqlBackupPassword,
      backupdir       => $backupdir,
      backupdatabases => [$userDbName], 
      backuprotate    => 1,
      time            => [$backupmysqlhour,$backupmysqlminute],
    }
  }
}
