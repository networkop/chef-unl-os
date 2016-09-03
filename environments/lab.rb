name "lab"
description "unl openstack lab"
default_attributes "os_lab" => {
  1 => {
    "role" => "controller",
    "fabric" => {
      "ip" => "10.0.0.0",
      "mask" => "255.255.255.254",
      "gw" => "10.0.0.1",
      "route" => "10.0.0.0/8"
    }
  },
  2 => {
    "role" => "compute",
    "fabric" => {
      "ip" => "10.0.0.2",
      "mask" => "255.255.255.254",
      "gw" => "10.0.0.3",
      "route" => "10.0.0.0/8"
    }
  },
  3 => {
    "role" => "compute",
    "fabric" => {
      "ip" => "10.0.0.4",
      "mask" => "255.255.255.254",
      "gw" => "10.0.0.5",
      "route" => "10.0.0.0/8"
    }
  }
}, "fabric" => {
  4 => {
    "role" => "leaf",
    "access" => {
      "swp1" => 1
    },
    "isl" => ["swp2", "swp3"]
  },
  5 => {
    "role" => "leaf",
    "access" => {
      "swp1" => 2
    },
    "isl" => ["swp2", "swp3"]
  },
  6 => {
    "role" => "leaf",
    "access" => {
      "swp1" => 3
    },
    "isl" => ["swp2", "swp3"]
  },
  7 => {
    "role" => "spine",
    "isl" => ["swp4", "swp2", "swp3"]
  },
  8 => {
    "role" => "spine",
    "isl" => ["swp4", "swp2", "swp3"]
  }
}

override_attributes "pxe" => {
    "net" => "169.254.0.0",
    "mask" => "255.255.255.0",
    "pfx"  => "169.254.0",
    "gw" => "169.254.0.1"
  }

