# Class: jenkins::cli::reload
#
# Command Jenkins to reload config.xml via the CLI.
#
class jenkins::cli::reload {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  # Reload all Jenkins config from disk (only when notified)
  # The command is marked Sensitive as jenkins::cli::cmd can contain a password
  exec { 'reload-jenkins':
    command     => Sensitive("${::jenkins::cli::cmd} reload-configuration"),
    path        => ['/bin', '/usr/bin'],
    tries       => 10,
    try_sleep   => 2,
    refreshonly => true,
  }
}
