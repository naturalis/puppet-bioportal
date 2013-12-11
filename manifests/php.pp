# == Class: bioportal::php
#
# php.pp for bioportal puppet module
#
# Author : Hugo van Duijn
#
class bioportal::php (
  $memory_limit        = '32M',
  $date_timezone       = 'Europe/Amsterdam',
  $upload_max_filesize = '10M',
) {

  php::ini { '/etc/php.ini':
    memory_limit        => $memory_limit,
    date_timezone       => $date_timezone,
    upload_max_filesize => $upload_max_filesize,
  }

  php::module { [ 'pgsql' ]: }
}
