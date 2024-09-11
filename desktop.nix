{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kitty
    libxkbcommon
    libGL

    # WINIT_UNIX_BACKEND=wayland
    wayland

    # WINIT_UNIX_BACKEND=x11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libX11

  ];
  environment.variables = {
    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath (
      with pkgs;
      [
        libxkbcommon
        libGL

        # WINIT_UNIX_BACKEND=wayland
        wayland

        # WINIT_UNIX_BACKEND=x11
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXi
        xorg.libX11
      ]
    )}";
  };
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "mmwave";
  # programs.hyprland.enable = true;
}
