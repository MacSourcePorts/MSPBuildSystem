export SOURCE_URL="https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.xz"
export CONFIGURE_ARGS="--enable-dri3 --enable-ge --enable-xevie --enable-xprint --enable-selinux --disable-silent-rules --enable-devel-docs=no --with-doxygen=no"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libxcb-composite.0.0.0.dylib" /usr/local/lib/libxcb-composite.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-damage.0.0.0.dylib" /usr/local/lib/libxcb-damage.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-dbe.0.0.0.dylib" /usr/local/lib/libxcb-dbe.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-dpms.0.0.0.dylib" /usr/local/lib/libxcb-dpms.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-dri2.0.0.0.dylib" /usr/local/lib/libxcb-dri2.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-dri3.0.1.0.dylib" /usr/local/lib/libxcb-dri3.0.1.0.dylib
sudo install_name_tool -id "@rpath/libxcb-ge.0.0.0.dylib" /usr/local/lib/libxcb-ge.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-glx.0.0.0.dylib" /usr/local/lib/libxcb-glx.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-present.0.0.0.dylib" /usr/local/lib/libxcb-present.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-randr.0.1.0.dylib" /usr/local/lib/libxcb-randr.0.1.0.dylib
sudo install_name_tool -id "@rpath/libxcb-record.0.0.0.dylib" /usr/local/lib/libxcb-record.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-render.0.0.0.dylib" /usr/local/lib/libxcb-render.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-res.0.0.0.dylib" /usr/local/lib/libxcb-res.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-screensaver.0.0.0.dylib" /usr/local/lib/libxcb-screensaver.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-shape.0.0.0.dylib" /usr/local/lib/libxcb-shape.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-shm.0.0.0.dylib" /usr/local/lib/libxcb-shm.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-sync.1.0.0.dylib" /usr/local/lib/libxcb-sync.1.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xevie.0.0.0.dylib" /usr/local/lib/libxcb-xevie.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xf86dri.0.0.0.dylib" /usr/local/lib/libxcb-xf86dri.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xfixes.0.0.0.dylib" /usr/local/lib/libxcb-xfixes.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xinerama.0.0.0.dylib" /usr/local/lib/libxcb-xinerama.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xinput.0.1.0.dylib" /usr/local/lib/libxcb-xinput.0.1.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xkb.1.0.0.dylib" /usr/local/lib/libxcb-xkb.1.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xprint.0.0.0.dylib" /usr/local/lib/libxcb-xprint.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xselinux.0.0.0.dylib" /usr/local/lib/libxcb-xselinux.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xtest.0.0.0.dylib" /usr/local/lib/libxcb-xtest.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xv.0.0.0.dylib" /usr/local/lib/libxcb-xv.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb-xvmc.0.0.0.dylib" /usr/local/lib/libxcb-xvmc.0.0.0.dylib
sudo install_name_tool -id "@rpath/libxcb.1.1.0.dylib" /usr/local/lib/libxcb.1.1.0.dylib

sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-composite.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-damage.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-dbe.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-dpms.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-dri2.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-dri3.0.1.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-ge.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-glx.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-present.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-randr.0.1.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-record.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-render.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-res.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-screensaver.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-shape.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-shm.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-sync.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xevie.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xf86dri.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xfixes.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xinerama.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xinput.0.1.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xkb.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xprint.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xselinux.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xtest.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xv.0.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libxcb.1.1.0.dylib @rpath/libxcb.1.1.0.dylib /usr/local/lib/libxcb-xvmc.0.0.0.dylib
