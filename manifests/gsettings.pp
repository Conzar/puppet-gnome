# @summary Sets a configuration key in Gnome's GSettings registry.
#
# @param [String] schema
#   The schema id.
#   Can you the command 'gsettings list-schemas' for a complete list.
#
# @param [String] key
#   The key to the schema path.
#
# @param [String] value
#   The value to set the schema/key pair to.
#
# @param [String] directory
#   The directory to apply for global settings.
#   If setting the user parameter, this setting is ignored.
#
# @param [String] priority
#   The priority of the modification to the settings.
#
# @param [Optional[String]] user
#   Apply the configuration only to the specified user instead of globally.
#
define gnome::gsettings(
  String           $schema,
  String           $key,
  String           $value,
  String           $directory = '/usr/share/glib-2.0/schemas',
  String           $priority  = '25',
  Optional[String] $user = undef,
) {
  anchor{"gnome::gsettings::${title}::begin":}

  if ($user == undef) {
    file { "${directory}/${priority}_${name}.gschema.override":
      content => "[${schema}]\n  ${key} = '${value}'\n",
      require => Anchor["gnome::gsettings::${title}::begin"],
    }

    exec { "change-${schema}-${key}":
      command     => "/usr/bin/glib-compile-schemas ${directory}",
      refreshonly => true,
      subscribe   => File["${directory}/${priority}_${name}.gschema.override"],
      before      => Anchor["gnome::gsettings::${title}::end"],
    }
  } else {
    exec { "change-${schema}-${key}":
      command => "dbus-launch gsettings set ${schema} ${key} ${value}",
      path    => '/usr/bin',
      user    => $user,
      require => Anchor["gnome::gsettings::${title}::begin"],
      before  => Anchor["gnome::gsettings::${title}::end"],
    }
  }

  anchor{"gnome::gsettings::${title}::end":
    require => Anchor["gnome::gsettings::${title}::begin"],
  }
}
