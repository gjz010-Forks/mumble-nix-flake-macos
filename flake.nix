{
  description = "Mumble voice chat software";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        stdenv = pkgs.stdenv;

        generic = overrides: source:
          stdenv.mkDerivation (source // overrides // {
            pname = overrides.type;
            version = source.version;
            nativeBuildInputs = [
              pkgs.cmake
              pkgs.pkg-config
              pkgs.qt5.wrapQtAppsHook
              pkgs.qt5.qttools
              pkgs.python3
              pkgs.xar
            ] ++ (overrides.nativeBuildInputs or [ ]);
            buildInputs = [
            ] ++ (overrides.buildInputs or [ ]);
            cmakeFlags = [  ] ++ (overrides.configureFlags or [ ]);
            preConfigure = ''
              patchShebangs scripts
            '';
            meta = with lib; {
              description = "Low-latency, high quality voice chat software";
              homepage = "https://mumble.info";
              license = licenses.bsd3;
              maintainers = [ ];
              platforms = platforms.darwin;
            };
          });

        client = source:
          generic {
            type = "mumble";
            nativeBuildInputs = [ pkgs.qt5.qttools ];
            buildInputs = [
              pkgs.boost
              pkgs.libopus
              pkgs.qt5.qtsvg
              pkgs.rnnoise
              pkgs.speex
              pkgs.boost
              pkgs.libogg
              pkgs.libvorbis
              pkgs.flac
              pkgs.libsndfile
              pkgs.protobuf_21
              pkgs.openssl
              pkgs.poco
              pkgs.darwin.apple_sdk.frameworks.ScriptingBridge
            ];
            configureFlags = [
              "-D server=OFF"
              "-D bundled-celt=ON"
              "-D bundled-opus=OFF"
              "-D bundled-speex=OFF"
              "-D bundled-rnnoise=OFF"
              "-D bundled-renamenoise=ON"
              "-D bundle-qt-translations=OFF"
              "-D update=OFF"
              "-D overlay-xcompile=OFF"
              "-D overlay=ON"
              "-D ice=OFF"
              "-D qtspeech=OFF"
              "-D warnings-as-errors=OFF"
              "-D test=OFF"
              "-D alsa=OFF"
              "-D pulseaudio=OFF"
              "-D pipewire=OFF"
              "-D crashreport=OFF"
              "-D optimize=true"
              "-D lto=OFF"
              "-DCMAKE_CXX_STANDARD=14"
            ];
          } source;

        source = rec {
          version = "1.5.634";
          src = pkgs.fetchFromGitHub {
            owner = "mumble-voip";
            repo = "mumble";
            rev = "v${version}";
            sha256 = "sha256-d9XmXHq264rTT80zphYcKLxS+AyUhjb19D3DuBJvMI4=";
            fetchSubmodules = true;
          };
        };
      in {
        packages = rec {
          mumble = client source;
          default = mumble;
        };
      });
}
