# Class: plesk
#
# This module manages plesk
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class plesk {
  #ruby-mysql is commond in debian and redhat.. hurrah!!
  package{ 'ruby-mysql':
    ensure => 'installed',
  }
}
