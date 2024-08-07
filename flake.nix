{
  description = "Data Analysis";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  outputs = { self, nixpkgs } @inputs:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
    in
    {
      devShell."x86_64-linux" = (pkgs.buildFHSUserEnv
        {
          name = "cuda-env";
          targetPkgs = pkgs: with pkgs; [
            git
            gcc11
            gitRepo
            gnupg
 
            cudaPackages.cutensor
            cudaPackages.nvidia_fs
            cudaPackages.libcurand
            cudaPackages.libcufile

            cudaPackages.libcublas
            cudaPackages.cuda_cccl

            cudaPackages.cuda_cupti

            autoconf
            curl
            procps
            gnumake
            util-linux
            m4
            gperf
            unzip
            cudatoolkit
            linuxPackages.nvidia_x11
            libGLU
            libGL
            xorg.libXi
            xorg.libXmu
            freeglut
            xorg.libXext
            xorg.libX11
            xorg.libXv
            xorg.libXrandr
            zlib
            ncurses5
            stdenv.cc
            binutils
          ];
          multiPkgs = pkgs: with pkgs; [ zlib ];
          runScript = "bash";
          profile = ''
            export CUDA_PATH=${pkgs.cudatoolkit}
            export LD_LIBRARY_PATH=${pkgs.cudatoolkit}/lib64:$LD_LIBRARY_PATH
            export LD_LIBRARY_PATH=${pkgs.cudatoolkit}/extras/CUPTI/lib64:$LD_LIBRARY_PATH
            export PATH=${pkgs.cudatoolkit}/bin:$PATH
          '';
        }).env;
    };
}

# export CUDA_PATH=${pkgs.cudatoolkit}
# export LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib
# export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
# export EXTRA_CCFLAGS="-I/usr/include"
