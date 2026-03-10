{ config, lib, pkgs, ... }:

let
  cfg = config.host;
in
{
  options.host = {
    hostName = lib.mkOption {
      type = lib.types.str;
    };

    ipv4Address = lib.mkOption {
      type = lib.types.str;
    };

    prefixLength = lib.mkOption {
      type = lib.types.int;
      default = 24;
    };

    gateway = lib.mkOption {
      type = lib.types.str;
    };

    interface = lib.mkOption {
      type = lib.types.str;
    };

    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    username = lib.mkOption {
      type = lib.types.str;
      default = "user";
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    sopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkMerge [{
    # Set time zone
    time.timeZone = "Europe/Vilnius";

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable experimental features
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # A list of names of users that have additional rights when connecting to the Nix daemon,
    # such as the ability to specify additional binary caches, or to import unsigned NARs.
    # You can also specify groups by prefixing them with @; for instance, @wheel means all users in the wheel group.
    # 
    # This is used by the deploy-rs tool
    nix.settings.trusted-users = [ "root" "@wheel" ];

    # Networking config
    networking = {
      hostName = cfg.hostName;
      interfaces.${cfg.interface}.ipv4.addresses = [
        {
          address = cfg.ipv4Address;
          prefixLength = cfg.prefixLength;
        }
      ];
      defaultGateway = {
        address = cfg.gateway;
        interface = cfg.interface;
      };
      nameservers = cfg.nameservers;
    };

    users.users.${cfg.username} = {
      isNormalUser = true;
      initialHashedPassword = "";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = cfg.sshKeys;
      #   packages = with pkgs; [
      #     tree
      #   ];
    };

    # Allow members of the wheel group to execute sudo without a password
    security.sudo.wheelNeedsPassword = false;

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      ports = [ 22 ]; # Default SSH port
      settings = {
        PasswordAuthentication = false; # Disable password authentication
      };
    };

    # This will automatically import SSH keys as age keys
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # This is using an age key that is expected to already be in the filesystem
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # This will generate a new key if the key specified above does not exist
    sops.age.generateKey = true;

    # Default system packages
    environment.systemPackages = with pkgs; [
      (import ../hosts/scripts/initialize.nix { inherit pkgs; })
      (import ../hosts/scripts/switch-host.nix { inherit pkgs; })

      htop
      vim
      wget
      git
      net-tools
      dig
    ];
  }
    (lib.mkIf (cfg.sopsFile != null) {
      sops.defaultSopsFile = cfg.sopsFile;
    })];
}
