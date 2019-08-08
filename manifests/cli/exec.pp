# == Define: jenkins::cli::exec
#
# A defined type for executing custom helper script commands via the Jenkins
# CLI.
#
define jenkins::cli::exec(
  Variant[String, Sensitive[String], Undef]                   $unless  = undef,
  Variant[String, Array, Sensitive[String], Sensitive[Array]] $command = $title,
) {

  include ::jenkins
  include ::jenkins::cli_helper
  include ::jenkins::cli::reload

  Class['jenkins::cli_helper']
    -> Jenkins::Cli::Exec[$title]
      -> Anchor['jenkins::end']

  # If we passed in a Sensitive command we need to unwrap it first
  # Otherwise the join/delete/flatten sequence won't work correctly
  $unwrapped_command = $command ? {
    Sensitive => $command.unwrap(),
    default   => $command,
  }

  # $command may be either a string or an array due to the use of flatten()
  $unwrapped_run = join(
    delete_undef_values(
      flatten([
        $::jenkins::cli_helper::helper_cmd,
        $unwrapped_command,
      ])
    ),
    ' '
  )

  # If we passed in a Sensitive command we want to make sure to wrap it again before use
  $run = $command ? {
    Sensitive => Sensitive($unwrapped_run),
    default   => $unwrapped_run,
  }

  if $unless {
    $environment_run = [ "HELPER_CMD=eval ${::jenkins::cli_helper::helper_cmd}" ]
  } else {
    $environment_run = undef
  }

  exec { $title:
    provider    => 'shell',
    command     => $run,
    environment => $environment_run,
    unless      => $unless,
    tries       => $::jenkins::cli_tries,
    try_sleep   => $::jenkins::cli_try_sleep,
    notify      => Class['jenkins::cli::reload'],
  }
}
