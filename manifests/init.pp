class ltscore (
  $fix_access_to_alsa     = true,
  $fix_access_to_messages = true,
  $fix_disable_services   = true,
  $fix_haldaemon          = true,
  $fix_updatedb           = true,
  $fix_systohc            = true,
  $fix_xinetd             = true,
  $localscratch           = true,
  $swappiness             = '30',
) {

  if ($fix_access_to_alsa == true) and (${::osfamily} == 'Suse') {
    exec { 'fix_access_to_alsa':
      command => 'sed -i \'s#NAME="snd/%k".*$#NAME="snd/%k",MODE="0666"#\' /etc/udev/rules.d/40-alsa.rules',
      path    => '/bin:/usr/bin',
      unless  => 'test -f /etc/udev/rules.d/40-alsa.rules && grep "snd.*0666" /etc/udev/rules.d/40-alsa.rules',
    }
  }

  if $fix_access_to_messages == true {
    file { '/var/log/messages' :
      mode => '0644',
    }
  }

  if ($fix_haldaemon == true) and (${::osfamily}${::lsbmajdistrelease} == 'Suse11' {
    service { 'haldaemon':
      enable => 'true',
    }
    exec { 'fix_haldaemon':
      command => 'sed -i \'/^HALDAEMON_BIN/a CPUFREQ="no"\' /etc/init.d/haldaemon'
      path    => '/bin:/usr/bin',
      unless  => 'grep CPUFREQ /etc/init.d/haldaemon',
      notify  => Service['haldaemon'],
    }
  }

# /!\ Todo: fix_disable_services is missing


  if ($fix_systohc == true) and ($::osfamily == 'Suse') and ($::virtual != 'physical') {
    exec { 'fix_systohc':
      command => 'sed -i \'s/SYSTOHC=.*yes.*/SYSTOHC="no"/\' /etc/sysconfig/clock'
      path    => '/bin:/usr/bin',
      onlyif  => 'grep SYSTOHC=.*yes.* /etc/sysconfig/clock'
    }
  }

  if ($fix_updatedb == true)  and ($::osfamily == 'Suse'){
    exec { 'fix_updatedb':
      command => 'sed -i \'s/RUN_UPDATEDB=.*yes.*/RUN_UPDATEDB=no/\' /etc/sysconfig/locate'
      path    => '/bin:/usr/bin',
      onlyif  => 'grep RUN_UPDATEDB=.*yes.* /etc/sysconfig/locate'
    }
  }

# /!\ Todo: make fix_xinetd: package -> file -> service

  if $fix_xinetd == true {
    package { 'xinetd' :
      ensure => 'installed',
    } ->
    file { '/etc/xinetd.d/echo' :
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template("eis_ltscore/pre1_0/xinetd_d_echo.erb"),
    } ~>
    exec { 'fix_xinetd':
      commando    => '/sbin/service xinetd restart',
      refreshonly => true,
    }
  }

  if $localscratch == true {
    file { '/local':
      ensure => directory,
      mode   => '0755',
    }
    file { '/local/scratch':
      ensure => directory,
      mode   => '1777',
    }
  }

  if $swappiness != '' {
    exec { 'swappiness':
      command => "/bin/echo ${swappiness} > /proc/sys/vm/swappiness",
      unless  => "/bin/grep '^${swappiness}$' /proc/sys/vm/swappiness",
    }
  }

}
