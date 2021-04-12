#!/bin/bash

# Exit script on first error
set -e

# Capture start_time
start_time=`date +%s`

# Source directory defined as location of install.sh
SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Install pipelinewise venvs in the present working directory
VENV_DIR=/opt/singer/.virtualenvs

clean_virtualenvs() {
    echo "Cleaning previous installations in $VENV_DIR"
    rm -rf $VENV_DIR
}

make_virtualenv() {
    echo "Making Virtual Environment for [$1] in $VENV_DIR"
    python3 -m venv $VENV_DIR/$1
    source $VENV_DIR/$1/bin/activate
    python3 -m pip install --upgrade pip setuptools wheel

    if [ -f "requirements.txt" ]; then
        python3 -m pip install --upgrade -r requirements.txt
    fi
    if [ -f "setup.py" ]; then
        PIP_ARGS=
        if [[ ! $NO_TEST_EXTRAS == "YES" ]]; then
            PIP_ARGS=$PIP_ARGS"[test]"
        fi

        python3 -m pip install --upgrade -e .$PIP_ARGS
    fi

    echo ""

    deactivate
}

install_connector() {
    echo
    echo "--------------------------------------------------------------------------"
    echo "Installing $1 connector..."
    echo "--------------------------------------------------------------------------"

    CONNECTOR_DIR=$SRC_DIR/singer-connectors/$1
    if [[ ! -d $CONNECTOR_DIR ]]; then
        echo "ERROR: Directory not exists and does not look like a valid singer connector: $CONNECTOR_DIR"
        exit 1
    fi

    cd $CONNECTOR_DIR
    make_virtualenv $1
}

print_installed_connectors() {
    cd $SRC_DIR

    echo
    echo "--------------------------------------------------------------------------"
    echo "Installed components:"
    echo "--------------------------------------------------------------------------"
    echo
    echo "Component            Version"
    echo "-------------------- -------"

    for i in `ls $VENV_DIR`; do
        source $VENV_DIR/$i/bin/activate
        VERSION=`python3 -m pip list | grep "$i[[:space:]]" | awk '{print $2}'`
        printf "%-20s %s\n" $i "$VERSION"
    done

    if [[ $CONNECTORS != "all" ]]; then
        echo
        echo "WARNING: Not every singer connector installed. If you are missing something use the --connectors=...,... argument"
        echo "         with an explicit list of required connectors or use the --connectors=all to install every available"
        echo "         connector"
    fi
}

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        # Do not print usage information at the end of the install
        --nousage)
            NO_USAGE="YES"
            ;;
        # Install with test requirements that allows running tests
        --notestextras)
            NO_TEST_EXTRAS="YES"
            ;;
        # Install extra connectors
        --connectors=*)
            CONNECTORS="${arg#*=}"
            shift
            ;;
        # Clean previous installation
        --clean)
            clean_virtualenvs
            exit 0
            ;;
        *)
            echo "Invalid argument: $arg"
            exit 1
            ;;
    esac
done

# Welcome message
if ! ENVSUBST_LOC="$(type -p "envsubst")" || [[ -z ENVSUBST_LOC ]]; then
  echo "envsubst not found but it's required to run this script. Try to install gettext or gettext-base package"
  exit 1
fi

# Set default and extra singer connectors
DEFAULT_CONNECTORS=(
    tap-salesforce
    tap-zendesk
    tap-mixpanel
    tap-twilio
    tap-pipedrive
    tap-zuora
    tap-stripe
    tap-shopify
    target-postgres
    target-postgres-datamill
    target-s3-csv
    transform-field
)

EXTRA_CONNECTORS=(
    tap-jira
    tap-kafka
    tap-mysql
    tap-postgres
    tap-s3-csv
    tap-snowflake
    tap-mongodb
    tap-github
    tap-slack
    target-snowflake
    target-redshift
    tap-adwords
    tap-oracle
    tap-zuora
    tap-google-analytics
)

# Install only the default connectors if --connectors argument not passed
if [[ -z $CONNECTORS ]]; then
    for i in ${DEFAULT_CONNECTORS[@]}; do
        install_connector $i
    done


# Install every available connectors if --connectors=all passed
elif [[ $CONNECTORS == "all" ]]; then
    for i in ${DEFAULT_CONNECTORS[@]}; do
        install_connector $i
    done
    for i in ${EXTRA_CONNECTORS[@]}; do
        install_connector $i
    done

# Install the selected connectors if --connectors argument passed
elif [[ ! -z $CONNECTORS ]]; then
    OLDIFS=$IFS
    IFS=,
    for connector in $CONNECTORS; do
        install_connector $connector
    done
    IFS=$OLDIFS
fi

# Capture end_time
end_time=`date +%s`
echo
echo "--------------------------------------------------------------------------"
echo "Singer connectors installed successfully in $((end_time-start_time)) seconds"
echo "--------------------------------------------------------------------------"

print_installed_connectors
