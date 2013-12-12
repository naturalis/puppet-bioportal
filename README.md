puppet-bioportal
===================

Puppet modules for deployment of bioportal framework

Parameters
-------------
All parameters can be read from hiera, set in init.pp or configured using foreman. 

Classes
-------------
- bioportal
- bioportal::mysql
- bioportal::instances
- bioportal::postgresql
- bioportal::backup
- bioportal::php

Dependencies
-------------
- vcsrepo
- puppetlabs/apache2 
- Jimdo/puppet-duplicity
- puppetlabs/postgresql ( v.3.2.0 )
- puppetlabs/mysql ( v.2.1.0 )
- thias/puppet-php

Examples
-------------
Hiera yaml
dest_id and dest_key are API keys for amazon s3 account


```
bioportal::instances
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
bioportal::bucket: 'linuxbackups'
bioportal::bucketfolder: 'bioportal'
bioportal::mysqlUser: 'bioportal'
bioportal::mysqlPassword: 'defaultpwd'

```
Puppet code
```
class { bioportal: }
```
Result
-------------
Server with running postgres server incl. postgis enabled database, running mysql server incl. database and user access. Apache webserver with virtualhost and php incl. pqsql and mysql modules. 

Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.

The module has been tested on:
- Ubuntu 12.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

