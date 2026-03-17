{
  sops = {
    secrets.k3s-token = { };
  };

  networking.firewall = {
    allowedTCPPorts = [
      # SSH
      22
      # HTTP
      80
      # HTTPS
      443
      # Embedded registry (spegel)
      5001
      # Node exporter
      9100
    ];
    # Flannel VXLAN
    allowedUDPPorts = [ 8472 ];
  };

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = "/run/secrets/k3s-token";
    serverAddr = "https://192.168.1.5:6443";
  };
}
