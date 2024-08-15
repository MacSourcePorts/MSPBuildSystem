export SOURCE_URL="https://www.libraw.org/data/LibRaw-0.21.2.tar.gz"
# export CONFIGURE_ARGS="ac_cv_prog_c_openmp=-Xpreprocessor -fopenmp ac_cv_prog_cxx_openmp=-Xpreprocessor -fopenmp LDFLAGS=-lomp"
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build.sh"