source "./source_urls.sh"

# ENet (Dune Dynasty multiplayer) -- the original ENet, not ENet6 (which
# installs as libenet6 / include/enet6, so they don't clash). Static only:
# it's small and MIT licensed, so it links straight into the game and there is
# no dylib to bundle. From the GitHub tag (enet.bespin.org has no https),
# which has no configure script, hence autoreconf.
export SOURCE_URL=${ENET_URL}
export SOURCE_FOLDER="enet-1.3.18"
export CONFIGURE_ARGS="--disable-shared --enable-static"

source "../common/get_source.sh"
(cd source/${SOURCE_FOLDER} && PATH="/usr/local/bin:$PATH" autoreconf -fi)
source "../common/make_build.sh"
