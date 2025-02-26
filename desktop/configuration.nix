
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; 
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  #Kernel
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelModules = [ "nvidia_uvm" "nvidia_modeset" "nvidia_drm" "nvidia" "glanimate" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "nvme" "sd_mod" "sr_mod" ];
  boot.supportedFilesystems = [ "ext4" "vfat" "ntfs" "exfat" ];
  
  
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = false;
  hardware.graphics.enable = true;
  hardware.nvidia.open = false;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # add flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "ookami";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome.enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  
  # Enable Docker support
  virtualisation.docker = {
    enable = true;
    # Enable docker daemon to start on boot
    enableOnBoot = true;
    # Optional: Enable nvidia-docker support if you use NVIDIA GPU
    enableNvidia = false;
    
    # Optional: Configure Docker daemon settings
    daemon.settings = {
      data-root = "/var/lib/docker";  # Default docker root directory
      storage-driver = "overlay2";     # Recommended storage driver
      log-driver = "journald";         # Use systemd journal for logging
      # Optional: Configure registry mirrors
      # registry-mirrors = [ "https://mirror.gcr.io" ];
    };
  };  


  # Enable containerd
  virtualisation.containerd = {
    enable = true;
    settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri" = {
        containerd.runtimes.runc = {
          runtime_type = "io.containerd.runc.v2";
          options = {
            SystemdCgroup = true;
          };
        };
        # Optional: Configure registry mirrors
        #registry.mirrors."docker.io" = {
        #  endpoint = [ "https://registry-1.docker.io" ];
        #};
      };
    };
  };  

  users.users.mfilio = {
    isNormalUser = true;
    description = "mfilio";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
       # enabled in system currently      
    ];
  };

  # Allow unfree packages and openssl-1.1.1w (which allows sublime4)
  # This does not affect openssl used with openssh
  nixpkgs.config = {
     allowUnfree = true;
     permittedInsecurePackages = [
       "openssl-1.1.1w"
     ];
  };


  # enable programs  
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.traceroute.enable = true;
  programs.iftop.enable = true;
  programs.htop.enable = true;
  programs.git.enable = true;
  programs.mtr.enable = true;
  programs.bcc.enable = true;
  programs.direnv.enable = true;
  programs.adb.enable = true;

  # disable programs
  programs.geary.enable = false;

  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  # shells
  programs.bash = {
     completion.enable = true;
     enableLsColors = true;
  };

  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.zsh.enable = true;


  environment.systemPackages = with pkgs; [
    # system utils
    openssh
    openssl
    psmisc
    cifs-utils
    nfs-utils
    microcodeAmd
    barrier
    gparted
    parted
    linuxPackages_zen.cpupower
    usbutils
    moreutils
    nvme-cli
    nmap
    netcat
    tree
    file
    xclip
    xdotool
    unzip
    pigz
    pciutils
    ugrep
    dnsutils
    ipset

    # windows on lan
    samba
    avahi
    wsdd
    
    # gnome
    enter-tex #replaced gnome-latex
    remmina
    gnomecast
    sushi
    gnome-shell
    gnome-shell-extensions
    gnome-disk-utility
    gnome-tweaks
    zenity
    gpaste
    cheese
    gnome.gvfs
    networkmanager-openvpn
    nautilus
    nautilus-python
    dconf-editor

    # gaming
    steam
    protonup-qt
    gamemode
    vulkan-tools

    # cli
    gh             #github
    glab           #gitlab
    awscli2
    vim
    wget
    curl
    jq
    yq
    screen
    tmux
    neofetch

    # Rust cli or replacements
    ripgrep-all
    ripgrep
    mtrace
    bat
    procs
    xh
    huniq
    rargs
    fzf
    sad
    delta
    diff-so-fancy
    shellharden
    xsv
    _0x


    # apps
    mplayer
    discord
    google-chrome
    chromium
    evolution
    terminator
    ghostty
    tilix
    feh
    zim
    vlc
    obs-studio
    mangohud
    mlt
    spotify
    zoom-us
    
    # Dev
    sops
    powershell
    k9s
    poetry
    nvidia-docker
    docker-compose
    containerd
    runc
    cni
    cni-plugins
    terraform
    rustup
    zed-editor
    sublime4
    sublime-merge
    go
    zig
    vscode
    kubectl
    fluxcd
    fluxctl
    google-chrome
    just
    kubernetes-helm
    istioctl
    gcc
    gnumake
    cmake
    ncurses
    gdbm
    tk
    readline
    bzip2
    xz
    zlib
    libffi
    sqlite
    (python312.withPackages(ps: with ps; [
       numpy
       httpie
       toolz
       requests
       beautifulsoup4
       playwright
    ]))
  ];

  # swap sudo for rs-sudo
  security.sudo-rs = {
    enable = true;
    package = pkgs.sudo-rs;
    wheelNeedsPassword = false;
  };

  # remove default and adjust env vars
  environment.variables.SUDO = "${pkgs.sudo-rs}/bin/sudo";
  environment.variables.SUDO_EDITOR = "${pkgs.sudo-rs}/bin/sudo-edit";

  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
    settings.PasswordAuthentication = false;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
 
  services.samba-wsdd = {
    enable = true;
    discovery = true;
  };


  # Crons
  systemd.timers."restart-barrier" = {
    enable = true;
    description = "Restarts barrier to prevent problems";
      timerConfig = {
        OnBootSec = "2m";
        OnUnitActiveSec = "2m";
        Unit = "barrier.service";
      };
    wantedBy = [ "timers.target" ];      
  };

  systemd.services."barrier" = {
    enable = true;
    description = "Kills all barrier processes and relaunches client";
    after =  [ "graphical-session.target" "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = { 
      ENVIRONMENT = [
        "XAUTHORITY=/run/user/%U/gdm/Xauthority"
        "DISPLAY=:1"
      ];
      ExecStart="/home/mfilio/bin/barrier_cron";
      Type = "forking";
      Resart = "always";
      User = "mfilio";
    };
  };

 
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
