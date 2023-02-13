# @summary 
#    Configure webserver for install server
#
# Configure the Apache webserver for the install server.
#
# @param kickstart_dir
#    The location where the kickstart/preseed files are stored.
#
# @param kickstart_url
#    The URL to access the kickstart/preseed files
#
# @param pub_dir
#    The location where public file like post install scripts are stored.
#
# @param pub_url
#    The URL to access the public files.
#
# @param repos_dir
#    The location where package repositories are stores if they are synced.
#
# @param repos_url
#    The URL to acces the package repositories.
#
# @param servername
#    The server name for the Apache vhost.
#
# @param status_allow_from
#    Array with IPs which are allowed to query the Apache status page.
#
# @param create_aliases
#     If aliases should be created.
#
# @param ssl_cert
#    SSL certificate file
#
# @param ssl_key
#    SSL key corresponding to the cert.
#
# @param ssl_chain
#    SSL chain file.
#
# @param ssl_certs_dir
# Directory where the SSL certs are located.
#
# @param documentroot
#    The document root directory for the Apache vhost.
#
# @example
#   include pxe_install::apache
#
# @api private
class pxe_install::apache (
  Stdlib::Unixpath $kickstart_dir,
  String $kickstart_url,
  Stdlib::Unixpath $pub_dir,
  String $pub_url,
  Stdlib::Unixpath $repos_dir,
  String $repos_url,
  String $servername,
  Array $status_allow_from,
  Boolean $create_aliases             = true,
  Boolean $purge_configs              = false,
  Optional[String] $ssl_cert          = '',
  Optional[String] $ssl_key           = '',
  Optional[String] $ssl_chain         = '',
  Optional[String] $ssl_certs_dir     = '',
  Optional[String] $documentroot      = '',
) {
  ensure_resource('file', ['/etc/pki/httpd', "/etc/pki/httpd/${servername}"], {
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
  })

  class { 'apache':
    default_vhost    => false,
    server_tokens    => 'Prod',
    server_signature => 'Off',
    trace_enable     => 'Off',
    purge_configs    => $purge_configs,
  }

  class { 'apache::mod::ssl':
  }

  class { 'apache::mod::status':
    allow_from => $status_allow_from,
  }

  class { 'apache::mod::info':
    allow_from => $status_allow_from,
  }

  if $create_aliases {
    $aliases = [
      {
        alias => $kickstart_url,
        path  => $kickstart_dir,
      },
      {
        alias => $pub_url,
        path  => $pub_dir,
      },
      {
        alias => $repos_url,
        path  => $repos_dir,
      },
    ]
  } else {
    $aliases = []
  }

  apache::vhost { $servername: #lint:ignore:security_apache_no_ssl_vhost
    port              => 80,
    docroot           => $documentroot,
    servername        => $servername,
    access_log_format => 'combined',
    aliases           => $aliases,
  }

  apache::vhost { "${servername} ssl":
    port                 => 443,
    ssl                  => true,
    ssl_cipher           => '"EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4"', #lint:ignore:140chars
    ssl_protocol         => 'TLSv1.2',
    ssl_honorcipherorder => 'on',
    ssl_options          => ['+StdEnvVars'],
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_key,
    ssl_chain            => $ssl_chain,
    ssl_certs_dir        => $ssl_certs_dir,
    docroot              => $documentroot,
    servername           => $servername,
    access_log_format    => 'combined',
    aliases              => $aliases,
  }
}
