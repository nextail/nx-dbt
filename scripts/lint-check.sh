SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
PRECOMMIT_VERSION="2.20.0"

#workdir
cd ${SCRIPTPATH}/..

wget -O pre-commit.pyz https://github.com/pre-commit/pre-commit/releases/download/v${PRECOMMIT_VERSION}/pre-commit-${PRECOMMIT_VERSION}.pyz
python3 pre-commit.pyz install
python3 pre-commit.pyz run --hook-stage manual --all-files
rm pre-commit.pyz
