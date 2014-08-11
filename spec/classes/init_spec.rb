require 'spec_helper'
describe 'ltscore' do

  platforms = {
    'RedHat-5' =>
      {
        :osfamily                     => 'RedHat',
        :lsbmajdistrelease            => '5',
        :is_virtual                   => true,
        :apply_fix_access_to_alsa     => false,
        :apply_fix_access_to_messages => true,
        :apply_fix_disable_services   => 'todo',
        :apply_fix_haldaemon          => false,
        :apply_fix_localscratch       => true,
        :apply_fix_swappiness         => true,
        :apply_fix_systohc            => false,
        :apply_fix_updatedb           => false,
        :apply_fix_xinetd             => true,
      },
    'RedHat-6' =>
      {
        :osfamily                     => 'RedHat',
        :lsbmajdistrelease            => '6',
        :is_virtual                   => true,
        :apply_fix_access_to_alsa     => false,
        :apply_fix_access_to_messages => true,
        :apply_fix_disable_services   => 'todo',
        :apply_fix_haldaemon          => false,
        :apply_fix_localscratch       => true,
        :apply_fix_swappiness         => true,
        :apply_fix_systohc            => false,
        :apply_fix_updatedb           => false,
        :apply_fix_xinetd             => true,
      },
    'RedHat-7' =>
      {
        :osfamily                     => 'RedHat',
        :lsbmajdistrelease            => '7',
        :is_virtual                   => true,
        :apply_fix_access_to_alsa     => false,
        :apply_fix_access_to_messages => true,
        :apply_fix_disable_services   => 'todo',
        :apply_fix_haldaemon          => false,
        :apply_fix_localscratch       => true,
        :apply_fix_swappiness         => true,
        :apply_fix_systohc            => false,
        :apply_fix_updatedb           => false,
        :apply_fix_xinetd             => true,
      },
    'Suse-10' =>
      {
        :osfamily                     => 'Suse',
        :lsbmajdistrelease            => '10',
        :is_virtual                   => true,
        :apply_fix_access_to_alsa     => true,
        :apply_fix_access_to_messages => true,
        :apply_fix_disable_services   => 'todo',
        :apply_fix_haldaemon          => false,
        :apply_fix_localscratch       => true,
        :apply_fix_swappiness         => true,
        :apply_fix_systohc            => true,
        :apply_fix_updatedb           => true,
        :apply_fix_xinetd             => true,
      },
    'Suse-11' =>
      {
        :osfamily                     => 'Suse',
        :lsbmajdistrelease            => '11',
        :is_virtual                   => true,
        :apply_fix_access_to_alsa     => true,
        :apply_fix_access_to_messages => true,
        :apply_fix_disable_services   => 'todo',
        :apply_fix_haldaemon          => true,
        :apply_fix_localscratch       => true,
        :apply_fix_swappiness         => true,
        :apply_fix_systohc            => true,
        :apply_fix_updatedb           => true,
        :apply_fix_xinetd             => true,
      },
  }

  describe 'with default values for parameters' do
    platforms.sort.each do |k,v|
      context "where osfamily is <#{v[:osfamily]}> and lsbmajdistrelease is <#{v[:lsbmajdistrelease]}>" do
        let :facts do
          {
            :osfamily          => v[:osfamily],
            :lsbmajdistrelease => v[:lsbmajdistrelease],
            :is_virtual        => v[:is_virtual],
          }
        end

        # exec { 'fix_access_to_alsa': }
        if v[:apply_fix_access_to_alsa] == true
          it {
            should contain_exec('fix_access_to_alsa').with({
              'command' => 'sed -i \'s#NAME="snd/%k".*$#NAME="snd/%k",MODE="0666"#\' /etc/udev/rules.d/40-alsa.rules',
              'path'    => '/bin:/usr/bin',
              'unless'  => 'test -f /etc/udev/rules.d/40-alsa.rules && grep "snd.*0666" /etc/udev/rules.d/40-alsa.rules',
            })
          }
        else
          it { should_not contain_exec('fix_access_to_alsa') }
        end

        # file { '/var/log/messages': }
        if v[:apply_fix_access_to_messages] == true
          it {
            should contain_file('/var/log/messages').with({
              'path'    => '/var/log/messages',
              'mode'    => '0644',
            })
          }
        else
          it { should_not contain_file('/var/log/messages') }
        end

        # service { 'haldaemon': }
        # exec { 'fix_haldaemon': }
        if v[:apply_fix_haldaemon] == true
          it {
            should contain_service('haldaemon').with({
              'enable'     => 'true',
            })
          }
          it {
            should contain_exec('fix_haldaemon').with({
              'command' => 'sed -i \'/^HALDAEMON_BIN/a CPUFREQ="no"\' /etc/init.d/haldaemon',
              'path'    => '/bin:/usr/bin',
              'unless'  => 'grep CPUFREQ /etc/init.d/haldaemon',
            })
          }
        else
          it { should_not contain_service('haldaemon') }
          it { should_not contain_exec('fix_haldaemon') }
        end

        # file { '/local': }
        # file { '/local/scratch': }
        if v[:apply_fix_localscratch] == true
          it {
            should contain_file('/local').with({
              'path'    => '/local',
              'ensure'  => 'directory',
              'mode'    => '0755',
            })
          }
          it {
            should contain_file('/local/scratch').with({
              'path'    => '/local/scratch',
              'ensure'  => 'directory',
              'mode'    => '1777',
            })
          }
        else
          it { should_not contain_file('/local') }
          it { should_not contain_file('/local/scratch') }
        end

        # exec { 'swappiness': }
        if v[:apply_fix_swappiness] == true
          it {
            should contain_exec('swappiness').with({
              'command' => '/bin/echo 30 > /proc/sys/vm/swappiness',
              'path'    => '/bin:/usr/bin',
              'unless'  => '/bin/grep \'^30$\' /proc/sys/vm/swappiness',
            })
          }
        else
          it { should_not contain_exec('swappiness') }
        end

        # exec { 'fix_systohc': }
        if v[:apply_fix_systohc] == true
          it {
            should contain_exec('fix_systohc').with({
              'command' => 'sed -i \'s/SYSTOHC=.*yes.*/SYSTOHC="no"/\' /etc/sysconfig/clock',
              'path'    => '/bin:/usr/bin',
              'onlyif'  => 'grep SYSTOHC=.*yes.* /etc/sysconfig/clock',
            })
          }
        else
          it { should_not contain_exec('fix_systohc') }
        end

        # exec { 'fix_updatedb': }
        if v[:apply_fix_updatedb] == true
          it {
            should contain_exec('fix_updatedb').with({
              'command' => 'sed -i \'s/RUN_UPDATEDB=.*yes.*/RUN_UPDATEDB=no/\' /etc/sysconfig/locate',
              'path'    => '/bin:/usr/bin',
              'onlyif'  => 'grep RUN_UPDATEDB=.*yes.* /etc/sysconfig/locate',
            })
          }
        else
          it { should_not contain_exec('fix_updatedb') }
        end

        # package { 'xinetd': }
        # file { '/etc/xinetd.d/echo': }
        # exec { 'fix_xinetd': }
        if v[:apply_fix_xinetd] == true
          echo_fixture = File.read(fixtures('echo'))
          it {
            should contain_package('xinetd').with({
              'ensure' => 'installed',
              'before' => 'File[/etc/xinetd.d/echo]',
            })
          }
          it {
            should contain_file('/etc/xinetd.d/echo').with({
              'path'    => '/etc/xinetd.d/echo',
              'mode'    => '0644',
              'owner'   => 'root',
              'group'   => 'root',
              'notify'  => 'Exec[fix_xinetd]',
            })
          }
          it { should contain_file('/etc/xinetd.d/echo').with_content(echo_fixture) }
          it {
            should contain_exec('fix_xinetd').with({
              'command'     => '/sbin/service xinetd restart',
              'refreshonly' => true,
            })
          }
        else
          it { should_not contain_package('xinetd') }
          it { should_not contain_file('/etc/xinetd.d/echo') }
          it { should_not contain_exec('fix_xinetd') }
        end

      end
    end
  end

#  describe "with optional parameters set" do
#    let :facts do
#      {
#        :osfamily   => 'RedHat',
#      }
#    end
#    let :params do
#      {
#      }
#    end
#  end

end
