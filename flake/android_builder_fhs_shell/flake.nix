{
  description = "My-Android build environment";
  nixConfig.bash-prompt = "[nix(Android_Builder)] ";
  inputs = {nixpkgs.url = "github:nixos/nixpkgs/23.11";};

  outputs = {
    self,
    nixpkgs,
  } @ inputs: let
    system = "x86_64-linux";
    pkgs =
      import nixpkgs
      {
        inherit system;
        config = {
          permittedInsecurePackages = ["python-2.7.18.7"];
        };
      };
  in {
    devShells.${system}.default = let
      android_builder_fhs_env = pkgs.buildFHSUserEnv {
        name = "android-env";
        targetPkgs = pkgs:
          with pkgs; [
            bc
            git
            gitRepo
            gnupg
            python2
            curl
            procps
            openssl
            gnumake
            nettools
            # For nixos < 19.03, use `androidenv.platformTools`
            androidenv.androidPkgs_9_0.platform-tools
            jdk
            schedtool
            util-linux
            m4
            gperf
            perl
            libxml2
            zip
            unzip
            bison
            flex
            lzop
            python3
          ];
        multiPkgs = pkgs:
          with pkgs; [
            zlib
            ncurses
          ];
        runScript = "bash";
        profile = ''
          export FHS=1
          export ALLOW_NINJA_ENV=true
          export USE_CCACHE=1
          export ANDROID_JAVA_HOME=${pkgs.jdk.home}
          # export LD_LIBRARY_PATH=/usr/lib:/usr/lib32

          export DEV_DIR=/home/nixos/Development
          export SOURCE_DIR=/home/nixos/Documents/code/android_kernel_motorola_sm8250
          cd $DEV_DIR || yes
          export PATH=$DEV_DIR/toolchains/clang-aosp/bin:$PATH
          export GCC_32=CROSS_COMPILE_ARM32=$DEV_DIR/toolchains/gcc-32/bin/arm-linux-androideabi-
          export GCC_64=CROSS_COMPILE=$DEV_DIR/toolchains/gcc-64/bin/aarch64-linux-android-
          export KERNEL_SOURCE=https://github.com/Nobooooody/android_kernel_motorola_sm8250
          export KERNEL_SOURCE_BRANCH=0warning0error_lineage-20
          export KERNEL_CONFIG=vendor/lineageos_pstar_lxc_docker_defconfig
          export KERNEL_IMAGE_NAME=Image
          export ARCH=arm64
          export EXTRA_CMDS="LD=ld.lld LOCALVERSION=-test_kernel"

          # Clang
          ## Custom
          export USE_CUSTOM_CLANG=false
          export CUSTOM_CLANG_SOURCE=
          export CUSTOM_CLANG_BRANCH=

          ### if your set USE CUSTOM CLANG to false than DO NOT CHANGE CUSTOM CMDS
          export CUSTOM_CMDS="CLANG_TRIPLE=aarch64-linux-gnu-"

          ## AOSP
          export CLANG_BRANCH=android13-release
          export CLANG_VERSION=r450784d

          # GCC
          export ENABLE_GCC_ARM64=true
          export ENABLE_GCC_ARM32=false

          # KernelSU flags
          export ENABLE_KERNELSU=true
          export KERNELSU_TAG=main

          # Configuration
          export DISABLE_CC_WERROR=false
          export ADD_KPROBES_CONFIG=true
          export ADD_OVERLAYFS_CONFIG=false

          # Ccache
          export ENABLE_CCACHE=true

          # DTBO image
          export NEED_DTBO=false

          # Build boot images
          export BUILD_BOOT_IMG=true

          cd $SOURCE_DIR || yes
        '';
        extraOutputsToInstall = ["dev"];
      };
    in
      pkgs.mkShell {
        name = "My-Android build environment";
        buildInputs = [
          android_builder_fhs_env
        ];
        shellHook = ''
          echo "Welcome in $name"
          exec android-env
        '';
      };
  };
}
