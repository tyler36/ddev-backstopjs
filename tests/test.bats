setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-backstop
  mkdir -p $TESTDIR
  export PROJNAME=test-addon-backstop
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart

  # backstop is installed and can show its version
  ddev backstop version | grep 'Command "version" successfully executed'

  # openReport and remote commands show an error message
  set +o pipefail
  ddev backstop openReport | grep -q 'This does not work for backstop in ddev'
  ddev backstop remote | grep -q 'This does not work for backstop in ddev'
}

# bats test_tags=release
#@test "install from release" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "# ddev add-on get drud/ddev-addon-template with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
#  ddev add-on get drud/ddev-addon-template
#  ddev restart >/dev/null
#  # Do something useful here that verifies the add-on
#  # ddev exec "curl -s elasticsearch:9200" | grep "${PROJNAME}-elasticsearch"
#}
