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
# envprovisioning.sh
#######################################################################################################
# (OPTIONAL) Local environment provisioning (e.g. cloning of local repos and credentials)

ssh-keyscan mylocalgitserver.com >> ~/.ssh/known_hosts  # Often needed for non public repos
git clone git@mylocalgitserver.com:local-environment-data/local-infra-info.git
cp local-infra-info/openstack/clouds.yaml "${BASE_FOLDER}"/ # Copy credentials to base folder
