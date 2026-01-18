# Cerberus

This is a NixOS configuration for Raspberry Pi 4 with PoE-HAT+, named Cerberus.
Cereberus is hosts multiple services including:

- Pi-hole (DNS + AdBlocker)
- Wireguard VPN server


## Build

```bash
nix run github:nix-community/nixos-generators -- -f sd-aarch64 --flake '.#cerberus' --system aarch64-linux -o ./cerberus.sd --cores 16
```

## Burn

```bash
caligula burn ~/nix-config/cerberus.sd/sd-image/nixos-image-sd-card-26.05.20251228.c0b0e0f-aarch64-linux.img.zst
```

## Know Issues/Limitations

- Flashed image will have a wrong date time, and since DNS is over TLS, it will not be able to resolve any domain names. You can fix this by setting the date manually after first boot:

```bash
date -s "2026-01-01 00:00:00"
```

- Poe-HAT fans are annoying loud and can be managed only declaratively, not via /boot/config.txt even docs state otherwise.

See docs: https://github.com/raspberrypi/linux/blob/590178d58b730e981099fdcb405053a000e79820/arch/arm/boot/dts/overlays/README#L4493
See source: https://github.com/NixOS/nixos-hardware/blob/cce68f4a54fa4e3d633358364477f5cc1d782440/raspberry-pi/4/poe-plus-hat.nix#L8

## Relevant Links

- [NixOS RaspberryPi 4 Guide](https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4)
