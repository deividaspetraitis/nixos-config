{pkgs, config, ...}:

{
  environment.systemPackages = with pkgs; [
    flac #  Library and tools for encoding and decoding the FLAC lossless audio file format
    pavucontrol # PulseAudio Volume Control
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
