{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libax25,
}:

let
  # Linux 7.1 removed these UAPI headers with the in-tree hamradio subsystem.
  # mod-orphan is their new upstream location.
  modOrphan = fetchFromGitHub {
    owner = "linux-netdev";
    repo = "mod-orphan";
    rev = "43fe23aae3e97f961841a6d64596985ee9f3e631";
    hash = "sha256-CEJ4xpe3Tla/v+ULEQe+drfcNbmKbW1c61dRrURDqAk=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ax25-tools";
  version = "0.0.10-rc5";

  strictDeps = true;

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ libax25 ];

  postPatch = ''
    cp ${modOrphan}/include/uapi/linux/{hdlcdrv.h,baycom.h} hdlcutil/
    substituteInPlace hdlcutil/hdrvcomm.h \
      --replace-fail '#include <linux/hdlcdrv.h>' '#include "hdlcdrv.h"' \
      --replace-fail '#include <linux/baycom.h>' '#include "baycom.h"'
  '';

  # src from linux-ax25.in-berlin.de remote has been
  # unreliable, pointing to github mirror from the radiocatalog
  src = fetchFromGitHub {
    owner = "radiocatalog";
    repo = "ax25-tools";
    tag = "ax25-tools-${finalAttrs.version}";
    hash = "sha256-yoFflC3KU3cKQEENj4MF793TvUdf38C2Q9B7nMuLgMg=";
  };

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var/lib"
  ];

  meta = {
    description = "Non-GUI tools used to configure an AX.25 enabled computer";
    homepage = "https://linux-ax25.in-berlin.de/wiki/Main_Page";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ sarcasticadmin ];
    platforms = lib.platforms.linux;
  };
})
