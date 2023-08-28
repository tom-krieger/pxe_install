# frozen_string_literal: true

require 'spec_helper'

describe 'pxe_install::apache' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'kickstart_dir'     => '/export/repos/kickstart',
          'kickstart_url'     => 'http://localhost/kickstart',
          'pub_dir'           => '/export/repos/pub',
          'pub_url'           => 'http://localhost/pub',
          'repos_dir'         => '/export/repos',
          'repos_url'         => 'http://localhost/repos',
          'servername'        => 'localhost',
          'status_allow_from' => ['127.0.0.1/32', '10.0.0.1/32'],
          'ssl_cert'          => '/etc/pki/httpd/localdomain.de/localdomain.de.cer',
          'ssl_key'           => '/etc/pki/httpd/localdomain.de/localdomain.de.key',
          'ssl_chain'         => '/etc/pki/httpd/localdomain.de/fullchain.cer',
          'ssl_certs_dir'     => '/etc/pki/httpd/localdomain.de/',
          'documentroot'      => '/var/www/html',
          'create_aliases'    => true,
        }
      end

      it { is_expected.to compile }
      it {
        is_expected.to contain_class('apache')
          .with(
            'default_vhost'    => false,
            'server_tokens'    => 'Prod',
            'server_signature' => 'Off',
            'trace_enable'     => 'Off',
          )

        is_expected.to contain_class('apache::mod::ssl')

        is_expected.to contain_class('apache::mod::status')
          .with(
            'requires' => 'ip 127.0.0.1/32 10.0.0.1/32',
          )

        is_expected.to contain_class('apache::mod::info')
          .with(
            'allow_from' => ['127.0.0.1/32', '10.0.0.1/32'],
          )

        is_expected.to contain_file('/etc/pki/httpd')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_file('/etc/pki/httpd/localhost')
          .with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )

        is_expected.to contain_apache__vhost('localhost')
          .with(
            'port'              => 80,
            'docroot'           => '/var/www/html',
            'servername'        => 'localhost',
            'access_log_format' => 'combined',
            'aliases'           => [
              {
                'alias' => 'http://localhost/kickstart',
                'path'  => '/export/repos/kickstart',
              },
              {
                'alias' => 'http://localhost/pub',
                'path'  => '/export/repos/pub',
              },
              {
                'alias' => 'http://localhost/repos',
                'path'  => '/export/repos',
              },
            ],
          )

        is_expected.to contain_apache__vhost('localhost ssl')
          .with(
            'port'                 => 443,
            'ssl'                  => true,
            'ssl_cipher'           => '"EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA '\
            'RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4"',
            'ssl_protocol'         => 'TLSv1.2',
            'ssl_honorcipherorder' => 'on',
            'ssl_options'          => ['+StdEnvVars'],
            'ssl_cert'             => '/etc/pki/httpd/localdomain.de/localdomain.de.cer',
            'ssl_key'              => '/etc/pki/httpd/localdomain.de/localdomain.de.key',
            'ssl_chain'            => '/etc/pki/httpd/localdomain.de/fullchain.cer',
            'ssl_certs_dir'        => '/etc/pki/httpd/localdomain.de/',
            'docroot'              => '/var/www/html',
            'servername'           => 'localhost',
            'access_log_format'    => 'combined',
            'aliases' => [
              {
                'alias' => 'http://localhost/kickstart',
                'path'  => '/export/repos/kickstart',
              },
              {
                'alias' => 'http://localhost/pub',
                'path'  => '/export/repos/pub',
              },
              {
                'alias' => 'http://localhost/repos',
                'path'  => '/export/repos',
              },
            ],
          )
      }
    end
  end
end
