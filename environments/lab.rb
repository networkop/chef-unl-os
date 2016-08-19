name "lab"
description "unl openstack lab"
default_attributes "os_lab" => {
  1 => {
    "role" => "controller",
    "fabric" => {
      "ip" => "10.0.0.2",
      "mask" => "255.255.255.254",
      "gw" => "10.0.0.1",
      "route" => "10.0.0.0/8"
    }
  },
  2 => {
    "role" => "compute",
    "fabric" => {
      "ip" => "10.0.0.4",
      "mask" => "255.255.255.254",
      "gw" => "10.0.0.3",
      "route" => "10.0.0.0/8"
    }
  },
  3 => {
    "role" => "compute",
    "fabric" => {
      "ip" => "10.0.0.6",
      "mask" => "255.255.255.254",
      "gw" => "10.0.0.5",
      "route" => "10.0.0.0/8"
    }
  }
}

override_attributes "pxe" => {
    "net" => "169.254.0.0",
    "mask" => "255.255.255.0",
    "pfx"  => "169.254.0",
    "gw" => "169.254.0.1"
  }

