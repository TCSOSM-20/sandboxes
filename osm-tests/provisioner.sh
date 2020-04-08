#!/usr/bin/env bash

#   Copyright 2020 Telefónica Investigación y Desarrollo S.A.U.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

#######################################################################################################
# PRE-REQUIREMENTS FOR THE ENVIRONMENT:
#######################################################################################################
# - There is at least one VIM available and reachable.
# - There is at least one OSM instance available and reachable.
# - The OSM instance(s) has (have) already at least one target added per VIM.

#######################################################################################################
# SOFTWARE PRE-REQUIREMENTS: (already covered for Vagrant)
#######################################################################################################
# - `authorized_keys` at `~/.ssh` with proper permissions
# - `id_rsa`, `id_rsa.pub` at `~/.ssh` with proper permissions
# - A functional `.gitconfig` file at `~` with proper permissions
# - `seedconfig.rc` and `patchconfig.rc` copied to `~/baseconfig`
# - `envprovisioning.sh` and `envconfig.rc` copied to `~/localconfig`

#######################################################################################################
# CONFIGURATION SEEDING
#######################################################################################################

# Folders where configuration is stored
BASE_CONFIG_FOLDER=baseconfig
LOCAL_CONFIG_FOLDER=localconfig # Default path. It can be reset dinamically by `seedconfig.rc` or `envprovisioning.sh` if needed

# Base configuration
if [ -f ${BASE_CONFIG_FOLDER}/seedconfig.rc ]
then
    cat ${BASE_CONFIG_FOLDER}/seedconfig.rc >> defaultenv.rc
    source ${BASE_CONFIG_FOLDER}/seedconfig.rc
else
    >&2 echo ################################################################################
    >&2 echo ERROR: Base configuration file ${BASE_CONFIG_FOLDER}/seedconfig.rc is missing.
    >&2 echo Please check README.md for details.
    >&2 echo Once fixed, rebuild your environment. E.g. for Vagrant:
    >&2 echo    vagrant destroy && vagrant up
    >&2 echo ################################################################################
    exit 1
fi

# (OPTIONAL) Devops patch configuration
if [ -f ${BASE_CONFIG_FOLDER}/patchconfig.rc ]
then
    cat ${BASE_CONFIG_FOLDER}/patchconfig.rc >> defaultenv.rc
    source ${BASE_CONFIG_FOLDER}/patchconfig.rc
fi

# (OPTIONAL) Local environment provisioning (e.g. cloning of local repos)
if [ -f ${LOCAL_CONFIG_FOLDER}/envprovisioning.sh ]
then
    source ${LOCAL_CONFIG_FOLDER}/envprovisioning.sh
fi

# Local environment configuration: VIM(s), OSM(s), credentials, etc.
if [ -f ${LOCAL_CONFIG_FOLDER}/envconfig.rc ]
then
    cat ${LOCAL_CONFIG_FOLDER}/envconfig.rc >> defaultenv.rc
    source ${LOCAL_CONFIG_FOLDER}/envconfig.rc
else
    >&2 echo ################################################################################
    >&2 echo WARNING: Local configuration file ${BASE_CONFIG_FOLDER}/envconfig.rc is missing.
    >&2 echo Please check README.md for details.
    >&2 echo If it is an error, once fixed, rebuild your environment. E.g. for Vagrant:
    >&2 echo    vagrant destroy && vagrant up
    >&2 echo Otherwise, you should add manually the appropriate environment variables later.
    >&2 echo ################################################################################
fi

#------------------------------------------------------------------------------------------------------

# Installs OSM client
sudo sed -i "/osm-download.etsi.org/d" /etc/apt/sources.list
wget -qO - https://osm-download.etsi.org/repository/osm/debian/ReleaseSEVEN/OSM%20ETSI%20Release%20Key.gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://osm-download.etsi.org/repository/osm/debian/ReleaseSEVEN stable devops IM osmclient"
sudo apt-get update
sudo apt-get install -y python3-pip
sudo -H python3 -m pip install python-magic pyangbind verboselogs
sudo apt-get install -y python3-osmclient

# Installs OpenStack client
##For Train version, uncomment the following two lines:
##sudo add-apt-repository -y cloud-archive:train
##sudo apt-get update
sudo apt-get install -y python3-openstackclient  # Installs Queens by default

# Installs Robot and all dependencies required for the tests

sudo -H python3 -m pip install --ignore-installed haikunator requests pyvcloud progressbar pathlib robotframework robotframework-seleniumlibrary robotframework-requests robotframework-SSHLibrary
curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
sudo apt-get install -y google-chrome-stable chromium-chromedriver
ln -s ${ROBOT_DEVOPS_FOLDER} robot

# Clones Devops repo to retrieve all Robot tests from OSM community
ssh-keyscan -p 29418 osm.etsi.org >> ~/.ssh/known_hosts
if [ -n "${ETSIUSERNAME}" ]     # If possible, uses ETSI's user name to make further contributions easier
then
    git clone "ssh://${ETSIUSERNAME}@osm.etsi.org:29418/osm/devops" && \
    (cd "devops" && curl https://osm.etsi.org/gerrit/tools/hooks/commit-msg > .git/hooks/commit-msg ; chmod +x .git/hooks/commit-msg)
else
    git clone "https://osm.etsi.org/gerrit/osm/devops"
fi

# if applicable, adds additional patches to devops repo (refer to `patchconfig.rc`)
[ -n "${DEVOPS_PATCH}" ] && git -C devops pull https://osm.etsi.org/gerrit/osm/devops ${DEVOPS_PATCH}

# Installs some additional packages to ease interactive troubleshooting
sudo apt-get install -y osm-devops
sudo snap install charm --classic
sudo snap install yq

# Copies VIM credentials in `clouds.yaml` (if applicable) to a proper location
if [ -f ${CLOUDS_PATH}/clouds.yaml ]; then
    sudo mkdir -p /etc/openstack
    sudo cp ${CLOUDS_PATH}/clouds.yaml /etc/openstack/
    rm ${CLOUDS_PATH}/clouds.yaml
fi

# Sets default environment to load automatically in `.bashrc`
cat defaultenv.rc >> ~/.bashrc
