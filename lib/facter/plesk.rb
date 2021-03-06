psafile = '/etc/psa/.psa.shadow'
if FileTest.exists?(psafile)
  pass = File.foreach(psafile).first.rstrip
  mysqlcmd = "mysql -u admin -p'#{pass}' psa -N -e "

  is_installed = false
  pkg = nil

  Facter.add("plesk") do
    confine :kernel => :linux
    os = Facter.value('operatingsystem')
    case os
      when "RedHat", "CentOS", "SuSE", "Fedora"
        pkg = Facter::Util::Resolution.exec 'rpm -q psa'
        is_installed = $?
      when "Debian", "Ubuntu"
        pkg = Facter::Util::Resolution.exec 'dpkg-query --show psa'
        pkg.tr!("\t", '-')
        is_installed = $?
      else
    end
    setcode do
      pkg if is_installed
    end
  end

  #Number of domains actived in plesk
  Facter.add('plesk_domain_active') do
    confine :kernel => :linux
    setcode do
      if is_installed then
        %x[#{mysqlcmd} "select count(id) from domains where status='0' and parentDomainId='0'"].strip
      end
    end
  end

  Facter.add('plesk_version') do
    confine :kernel => :linux
    setcode do
      if is_installed then
        %x[#{mysqlcmd} "SELECT val FROM misc WHERE param = 'version'"].strip
      end
    end
  end

  #Number of domains licensed in plesk
  Facter.add("plesk_domain_licensed") do
    confine :kernel => :linux
    lic = 0
    m = ''
    filenames = Dir['/etc/sw/keys/keys/key*']
    filenames.each do |filename|
      if FileTest.exists?(filename)
        File.foreach(filename) do |line|
          if m = /domains core:type=\"integer\">(.+)<\//.match(line)
            lic = m[1]
            break
          end
        end
      end
    end
    setcode do
      lic
    end
  end
end
