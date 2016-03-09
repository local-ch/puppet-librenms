# == Class: librenms::add_device
#
# This adds hosts which have the class librenms::device to the librenms database.
#
# === Authors
#
# Andre Timmermann librenms@darktim.de
#
# === Copyright
#
# Copyright (C) 2016 Andre Timmermann
#
class librenms::add_device {

  # Add devices to librenms
  Exec <<| tag == 'librenms-add_device' |>>
}

