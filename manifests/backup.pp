# Parameters:
#
class bioportal::backup (
  $backuphour = undef,
  $backupminute = undef,
  $backupdir = undef,
  $folder = undef,
  $bucket = undef,
  $dest_id = undef,
  $dest_key = undef,
  $cloud = undef,
  $pubkey_id = undef,
  $full_if_older_than = undef,
  $remove_older_than = undef,
  $backup_format = 'plain',
)
{
  notify {'Backup enabled':}

  # Create backup job using duplicity
  duplicity { 'backup':
    directory          => $backupdir,
    folder             => $folder,
    bucket             => $bucket,
    dest_id            => $dest_id,
    dest_key           => $dest_key,
    cloud              => $cloud,
    pubkey_id          => $pubkey_id,
    hour               => $backuphour,
    minute             => $backupminute,
    full_if_older_than => $full_if_older_than,
    remove_older_than  => $remove_older_than,
    pre_command        => '/usr/local/sbin/filebackup.sh && /usr/local/sbin/pgsql-backup.sh',
    require            => Class['mysql::server::backup'],
  }

  # create backup script for files 
  file { "/usr/local/sbin/filebackup.sh":
    content => template('bioportal/filebackup.sh.erb'),
    mode    => '0700',
  }

  # Create postgres backup script
  file { '/usr/local/sbin/pgsql-backup.sh':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('bioportal/pgsql-backup.sh.erb'),
  }

}
