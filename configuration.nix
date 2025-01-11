{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  systemd.services.vscode-server = {
    description = "vscode serve-web";
    after = [ "network-pre.target" ];
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.User = "robertwendt";
    script = ''
      ${pkgs.vscode}/bin/code serve-web --without-connection-token --host 0.0.0.0 --port 4321 --extensions-dir /home/alice/.vscode/extensions | ${pkgs.nix}/bin/nix run github:r33drichards/fix-vscode-server ${pkgs.nodejs}/bin/node
    '';
    serviceConfig.WorkingDirectory = "/Users/robertwendt";
    serviceConfig.Environment = "PATH=${pkgs.git}/bin:${pkgs.nix}/bin:/run/current-system/sw/bin:/usr/bin:/bin";

  };

  services.caddy = {
    enable = true;
    virtualHosts."nixos.jjk.is" = {
      extraConfig = ''
        respond "Hello World"
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
