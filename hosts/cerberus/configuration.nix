# configuration.nix

{ pkgs, config, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vilnius";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking config. important for ssh!
  networking = {
    hostName = "cerberus";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.1.1"; # or whichever IP your router is
      interface = "eth0";
    };
  };


  # Define the default shell assigned to user accounts.
  users.defaultUserShell = pkgs.zsh;

  # the user account on the machine
  users.users.cerberus = {
    isNormalUser = true;
    initialHashedPassword = "";
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDa2OjDgz4VVeOLQTNjpXrLsYIX8XtJOKicgfvhOXpeCoZlMQl0mTCU80rrgLZCckoDMCGB2GRrajs3mwYvX6HSAJgXKIUpGFqVcNHigI6eNXv5dXhJ4Tw1fJl6xgInLqt6IpzYnONKiMM2ZZvNErTa/NuI5upRlpROPyn3EWbVUVTQ/cfppz7aCijoVCrkmNldpepXu8rYlyTnCWF8xZNDyL+ZYAxq2Kap5J9oIgJbqIXZqjtO0pp5oJQC64ExA8QVakC4UH9x9uzDSnvInIG8Ri3v2Jg5IFBCdGBpnK3YUU7YVVkIJ9QBLjDHyqWgrr/0p5lF+Iid6+jfY/OSieTP"
    ];
  };

  # A list of permissible login shells for user accounts.
  # /bin/sh is placed into this list implicitly.
  environment.shells = with pkgs; [ zsh ];

  # I use neovim as my text editor, replace with whatever you like
  environment.systemPackages = with pkgs; [
    (import ./scripts/initialize.nix { inherit pkgs; })
    (import ../scripts/switch-user.nix { inherit pkgs; })
    (import ../scripts/switch-host.nix { inherit pkgs; })

    neovim
    wget
    git

    ## Network tools
    net-tools
    dig
  ];

  # Z Shell must be enabled system-wide.
  # Otherwise it won't source the necessary files.
  programs.zsh = {
    enable = true;
  };

  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  # Enable Pi-hole services
  services.pihole-ftl = {
    enable = true;

    # Open ports in the firewall for pihole-FTL’s DHCP server.
    openFirewallDHCP = true; # TODO do I need this?

    # Open ports in the firewall for pihole-FTL’s DNS server.
    openFirewallDNS = true; # TODO do I need this?

    # Open ports in the firewall for pihole-FTL’s webserver, as configured in settings.webserver.port.
    openFirewallWebserver = true; # TODO do I need this?

    # Blocklists
    lists = [
      {
        url = "https://easylist.to/easylist/easylist.txt";
        type = "block";
        enabled = true;
        description = "EasyList";
      }
      {
        url = "https://easylist.to/easylist/easyprivacy.txt";
        type = "block";
        enabled = true;
        description = "EasyPrivacy";
      }
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        type = "block";
        enabled = true;
        description = "Steven Black Hosts";
      }
    ];
    settings = {
      dns = {
        # Array of upstream DNS servers used by Pi-hole
        # Example: [ "8.8.8.8", "127.0.0.1#5335", "docker-resolver" ]
        #
        # Possible values are:
        #     array of IP addresses and/or hostnames, optionally with a port (#...)
        upstreams = [ "127.0.0.1#5335" ];

        # If set, A and AAAA queries for plain names, without dots or domain parts, are never
        # forwarded to upstream nameservers
        domainNeeded = true; ### CHANGED, default = false

        # If set, the domain is added to simple names (without a period) in /etc/hosts in the
        # same way as for DHCP-derived names
        expandHosts = true; ### CHANGED, default = false

        rateLimit = {
          # Rate-limited queries are answered with a REFUSED reply and not further processed by
          # FTL.
          # The default settings for FTL's rate-limiting are to permit no more than 1000 queries
          # in 60 seconds. Both numbers can be customized independently. It is important to note
          # that rate-limiting is happening on a per-client basis. Other clients can continue to
          # use FTL while rate-limited clients are short-circuited at the same time.
          # For this setting, both numbers, the maximum number of queries within a given time,
          # and the length of the time interval (seconds) have to be specified. For instance, if
          # you want to set a rate limit of 1 query per hour, the option should look like
          # dns.rateLimit.count=1 and dns.rateLimit.interval=3600. The time interval is relative
          # to when FTL has finished starting (start of the daemon + possible delay by
          # DELAY_STARTUP) then it will advance in steps of the rate-limiting interval. If a
          # client reaches the maximum number of queries it will be blocked until the end of the
          # current interval. This will be logged to /var/log/pihole/FTL.log, e.g. Rate-limiting
          # 10.0.1.39 for at least 44 seconds. If the client continues to send queries while
          # being blocked already and this number of queries during the blocking exceeds the
          # limit the client will continue to be blocked until the end of the next interval
          # (FTL.log will contain lines like Still rate-limiting 10.0.1.39 as it made additional
          # 5007 queries). As soon as the client requests less than the set limit, it will be
          # unblocked (Ending rate-limitation of 10.0.1.39).
          # Rate-limiting may be disabled altogether by setting both values to zero (this
          # results in the same behavior as before FTL v5.7).
          # How many queries are permitted...
          count = 0; ### CHANGED, default = 1000

          # ... in the set interval before rate-limiting?
          interval = 0; ### CHANGED, default = 60
        };
      };

      dhcp = {
        # Is the embedded DHCP server enabled?
        # TODO
        active = true; ### CHANGED, default = false

        # Start address of the DHCP address pool
        #
        # Possible values are:
        #     <valid IPv4 address> or empty string (""), e.g., "192.168.0.10"
        start = "192.168.1.100"; ### CHANGED, default = ""

        # End address of the DHCP address pool
        #
        # Possible values are:
        #     <valid IPv4 address> or empty string (""), e.g., "192.168.0.250"
        end = "192.168.1.254"; ### CHANGED, default = ""

        # Address of the gateway to be used (typically the address of your router in a home
        # installation)
        #
        # Possible values are:
        #     <valid IPv4 address> or empty string (""), e.g., "192.168.0.1"
        router = "192.168.1.1"; ### CHANGED, default = ""

        # If the lease time is given, then leases will be given for that length of time. If not
        # given, the default lease time is one hour for IPv4 and one day for IPv6.
        #
        # Possible values are:
        #     The lease time can be in seconds, or minutes (e.g., "45m") or hours (e.g., "1h")
        #     or days (like "2d") or even weeks ("1w"). You may also use "infinite" as string
        #     but be aware of the drawbacks
        leaseTime = "24h"; ### CHANGED, default = ""
      };

    };
  };

  services.pihole-web = {
    enable = true;
    ports = [
      "80r" # r: non-SSL port to redirect to the first available SSL port.
      "443s" # s: for the port to be used for SSL.
    ];
  };


  services.unbound = {
    enable = true;
    settings = {
      server = {
        # If no logfile is specified, syslog is used
        # logfile: "/var/log/unbound/unbound.log"
        verbosity = 3;

        interface = "127.0.0.1";
        port = 5335;
        do-ip4 = "yes";
        do-udp = "yes";
        do-tcp = "yes";

        # May be set to no if you don't have IPv6 connectivity
        do-ip6 = "yes";

        # You want to leave this to no unless you have *native* IPv6. With 6to4 and
        # Terredo tunnels your web browser should favor IPv4 for the same reasons
        prefer-ip6 = "no";

        # Use this only when you downloaded the list of primary root servers!
        # If you use the default dns-root-data package, unbound will find it automatically
        #root-hints: "/var/lib/unbound/root.hints"

        # Trust glue only if it is within the server's authority
        harden-glue = "yes";

        # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes BOGUS
        harden-dnssec-stripped = "yes";

        # Don't use Capitalization randomization as it known to cause DNSSEC issues sometimes
        # see https://discourse.pi-hole.net/t/unbound-stubby-or-dnscrypt-proxy/9378 for further details
        use-caps-for-id = "no";

        # Reduce EDNS reassembly buffer size.
        # IP fragmentation is unreliable on the Internet today, and can cause
        # transmission failures when large DNS messages are sent via UDP. Even
        # when fragmentation does work, it may not be secure; it is theoretically
        # possible to spoof parts of a fragmented DNS message, without easy
        # detection at the receiving end. Recently, there was an excellent study
        # >>> Defragmenting DNS - Determining the optimal maximum UDP response size for DNS <<<
        # by Axel Koolhaas, and Tjeerd Slokker (https://indico.dns-oarc.net/event/36/contributions/776/)
        # in collaboration with NLnet Labs explored DNS using real world data from the
        # the RIPE Atlas probes and the researchers suggested different values for
        # IPv4 and IPv6 and in different scenarios. They advise that servers should
        # be configured to limit DNS messages sent over UDP to a size that will not
        # trigger fragmentation on typical network links. DNS servers can switch
        # from UDP to TCP when a DNS response is too big to fit in this limited
        # buffer size. This value has also been suggested in DNS Flag Day 2020.
        edns-buffer-size = 1232;

        # Perform prefetching of close to expired message cache entries
        # This only applies to domains that have been frequently queried
        prefetch = "yes";

        # One thread should be sufficient, can be increased on beefy machines. In reality for most users running on small networks or on a single machine, it should be unnecessary to seek performance enhancement by increasing num-threads above 1.
        num-threads = "1";

        # Ensure kernel buffer is large enough to not lose messages in traffic spikes
        so-rcvbuf = "1m";

        # Ensure privacy of local IP ranges
        private-address = [
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"

          # Ensure no reverse queries to non-public IP ranges (RFC6303 4.2)
          "192.0.2.0/24"
          "198.51.100.0/24"
          "203.0.113.0/24"
          "255.255.255.255/32"
          "2001:db8::/32"
        ];
      };
    };
  };


  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ]; # Default SSH port
    settings = {
      PasswordAuthentication = false; # Disable password authentication
    };
  };


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
