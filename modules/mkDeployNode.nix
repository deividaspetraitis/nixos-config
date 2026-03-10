{ self, deploy-rs }:

{ host, system }: {
  # The hostname of your server. Can be overridden at invocation time with a flag.
  hostname = host;

  profiles.system = {
    # This is the user that deploy-rs will use when connecting.
    # This will default to your own username if not specified anywhere
    sshUser = "ops";

    # This is the user that the profile will be deployed to (will use sudo if not the same as above).
    # If `sshUser` is specified, this will be the default (though it will _not_ default to your own username)
    user = "root";

    # A derivation containing your required software, and a script to activate it in `${path}/deploy-rs-activate`
    # For ease of use, `deploy-rs` provides a function to easily add the required activation script to any derivation
    # Both the working directory and `$PROFILE` will point to `profilePath`
    path = deploy-rs.lib.${system}.activate.nixos
      self.nixosConfigurations.${host};
  };
}
