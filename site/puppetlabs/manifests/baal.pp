# Class: puppetlabs::baal
#
# This class installs and configures Baal
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppetlabs::baal {

  ###
  # Mysql
  #
  $mysql_root_pw = 'c@11-m3-m1st3r-p1t4ul'
  include mysql::server

  ###
  # Base
  #
  #include puppetlabs_ssl
  #include account::master
  #include vim

  ###
  # Bacula
  #
  $bacula_password = 'pc08mK4Gi4ZqqE9JGa5eiOzFTDPsYseUG'
  $bacula_director = 'baal.puppetlabs.com'
  class { "bacula":
    director => $bacula_director,
    password => $bacula_password,
  }

  class { "bacula::director":
    db_user => 'bacula',
    db_pw   => 'qhF4M6TADEkl',
  }

  bacula::director::pool {
    "PuppetLabsPool-Full":
      #volret      => "1 months",
      volret      => "30 days",
      maxvolbytes => '2000000000',
      maxvoljobs  => '2',
      maxvols     => "20",
      label       => "Full-";
    "PuppetLabsPool-Inc":
      volret      => "14 days",
      maxvolbytes => '4000000000',
      maxvoljobs  => '50',
      maxvols     => "10",
      label       => "Inc-";
  }

  bacula::fileset {
    "Common":
      files => ["/etc"],
  }

  bacula::job {
    "${fqdn}":
      files    => ["/var/lib/bacula/mysql"],
  }

  ###
  # Monitoring
  #
  file { "/etc/nagios":
    ensure => link,
    target => "/etc/nagios3",
  }
  class { "nagios::server": site_alias => "nagios.puppetlabs.com"; }
  include nagios::webservices
  include nagios::dbservices
  include nagios::pagerduty
  nagios::website { 'nagios.puppetlabs.com': auth => 'monit:5kUg8uha', }
  nagios::website { 'dashboard.puppetlabs.com': auth => 'monit:5kUg8uha', }
  nagios::website { 'munin.puppetlabs.com': auth => 'monit:5kUg8uha', }
  nagios::website { 'docs.puppetlabs.com': } # monitored here to avoid resource collision

  # Munin
  if $environment == 'production' {
    class { "munin::server": site_alias => "munin.puppetlabs.com"; }
    include munin::dbservices
    include munin::passenger
    include munin::puppet
    include munin::puppetmaster
  }

  apache::vhost { $fqdn:
    options  => "None",
    priority => '08',
    port     => '80',
    docroot  => '/var/www',
  }

  # VPN for internal monitoring and DNS Resolution
  openvpn::client {
    "node_$hostname":
      server => "office.puppetlabs.com",
  }

  # DNS resolution to internal hosts
  include unbound
  unbound::stub { "puppetlabs.lan": address => '192.168.100.1' }

  # zleslie: stop dhclient from updating resolve.conf
  file { "/etc/dhcp3/dhclient-enter-hooks.d/nodnsupdate":
    owner   => root,
    group   => root,
    mode    => 755,
    content => "#!/bin/sh\nmake_resolv_conf(){\n:\n}",
  }

  # Use unbound
  file { "/etc/resolv.conf":
    owner  => root,
    group  => root,
    mode   => 644,
    source => "puppet:///modules/puppetlabs/local_resolv.conf";
  }

}

