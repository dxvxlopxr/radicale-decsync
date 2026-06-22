{
  self,
  inputs,
  system,
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  radicale-pkg = pkgs.python3Packages.buildPythonPackage rec {
    pname = "radicale";
    version = "3.7.4";
    pyproject = true;

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-OsGGC+7JefXlnOF4oz8hVJ6VuZPAdzD17BqWlv4Qfzw=";
    };
    build-system = with pkgs.python3Packages; [
      setuptools
    ];
    propagatedBuildInputs = with pkgs.python3Packages; [
      defusedxml
      libpass
      bcrypt
      vobject
      pika
      requests
    ];
    doCheck = false;
  };
  libdecsync-pkg = pkgs.python3Packages.buildPythonPackage rec {
    pname = "libdecsync";
    version = "2.2.1";
    format = "setuptools";

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Mukjzjumv9VL+A0maU0K/SliWrgeRjAeiEdN5a83G0I=";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [
      setuptools
    ];
    postFixup = ''
      patchelf --add-needed libcrypt.so.1 \
        --add-rpath ${pkgs.libxcrypt-legacy}/lib \
        $out/lib/python3.13/site-packages/libdecsync/libs/libdecsync_amd64.so
    '';
    nativeBuildInputs = [ pkgs.patchelf ];
    doCheck = false;
  };
  radicale-decsync = pkgs.python3Packages.buildPythonPackage {
    pname = "radicale-storage-decsync";
    version = "git";
    pyproject = true;

    src = self;

    build-system = with pkgs.python3Packages; [
      uv-build
    ];

    propagatedBuildInputs = [
      radicale-pkg
      libdecsync-pkg
    ];

    doCheck = false;
  };
  radicaleWithDecsync = pkgs.python3.withPackages (ps: [
    self.packages.${system}.default
  ]);
in
{
  default = radicale-decsync;
  inherit radicale-decsync radicaleWithDecsync;
}
