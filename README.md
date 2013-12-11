puppet-bioportal
===================

Puppet modules for deployment of Nederlands Soortenregister 

Parameters
-------------
All parameters are read from hiera

Classes
-------------
- bioportal
- bioportal::database
- bioportal::instances
- bioportal::restore
- bioportal::backup


Dependencies
-------------
- vcsrepo
- apache2 module from puppetlabs
- Jimdo/puppet-duplicity

Examples
-------------
Hiera yaml
dest_id and dest_key are API keys for amazon s3 account


```
bioportal:
  www.bioportal.nl:
    serveraliases: 'nederlandssoortenregister.nl'
    aliases:
      - alias: '/linnaeus_ng'
        path: '/var/www/bioportal/www'
    docroot: /var/www/bioportal
    directories:
      - path: '/var/www/bioportal'
        options: '-Indexes FollowSymLinks MultiViews'
    port: 80
    ssl: no
    serveradmin: aut@naturalis.nl
    priority: 10
bioportal::backup: true
bioportal::backuphour: 5
bioportal::backupminute: 5
bioportal::backupdir: '/tmp/backups'
bioportal::dest_id: 'provider_id'
bioportal::dest_key: 'provider_key'
bioportal::restore: true
bioportal::bucket: 'linuxbackups'
bioportal::bucketfolder: 'bioportal'
bioportal::mysqlUser: 'linnaeus_user'
bioportal::mysqlPassword: 'skgh23876SDFSD2342

```
Puppet code
```
class { bioportal: }
```
Result
-------------
Working webserver with mysql, restored from duplicity, code from subversion and config files based on templates. with daily duplicity backup.

Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.

The module has been tested on:
- Ubuntu 12.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

