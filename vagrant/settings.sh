#!/bin/bash

# Example custom settings file. Copy this to settings.sh in the same directory
# to customize any of the listed installation variables. Default values are
# shown in the commented out lines.

PORTS_TO_CHECK="2232"

# Directory where the Vagrantfile and development deployment scripts live. It
# will be auto-configured by the deployment script, and is included here only
# for reference.
#VAGRANT_CONFIG_DIR=

# Install path for the virtual machine. Make sure that the user executing the
# installation script has permissions to create this directory.
VM_INSTALL_DIR="/usr/local/vagrant/unvideo"

# Box name to use for the Vagrantfile, config.vm.box setting.
VAGRANT_VM_BOX="tiwilliam/debian-8.0"

# Full path to the Git checkout of the repository on the host.
# If the directory does not already exist, then Git will be used to clone the
# repository to this directory, using the URL and branch configured below.
#GIT_CODE_DIR=""

# The Git URL to use when cloning the repository.
#GIT_CLONE_URL=""

# The Git branch to use when checking out the repository.
#GIT_CODE_BRANCH="master"

# Directory where the salt and pillar file roots are located. This is auto
# configured by the deployement script, so unless you're doing something
# custom, it's advised not to edit it.
#SALT_DIR="`dirname $VAGRANT_CONFIG_DIR`/salt"

# The port on the host to use for connecting to the VM's SSH daemon.
SSH_PORT="2232"

# The label for the entry to be placed in .ssh/config.
SSH_CONFIG_LABEL="unvideo"

# The minion ID to be used in /etc/salt/minion.
SALT_MINION_ID="voip.xylil.com"

ALLOW_VM_FILE_SYNC_TIME="no"
