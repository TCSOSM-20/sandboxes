# Vagrant Sandboxes for OSM

Copyright 2020 Telefónica Investigación y Desarrollo S.A.U.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Goal

The goal is adopting a methodology for local testing that is fully repeatable and well-known by the Depops MDL team in OSM.

This means that:

- Local testers should use (and rebuild regularly) the appropriate sandbox to perform tests and/or contributions to test plans, so that potential issues can be reliably diagnosed and solved.
- This means that all known changes in the installation procedures of any sandbox will be captured in the companion "provisioner" script (typically, `provisioner.sh`), so that the exact procedure can be well-known and testable by everyone.
- In case something that was known to work in a sandbox started to fail:
  - It should be reported as a bug if there were no further contributions to the sandbox, since it is likely to be a gap in the knowledge/testing of the corresponding provisioning procedure, that might have changed over time (e.g new dependencies, change of repositories, hardcoded locations, etc.)
  - In case new contributions (e.g. new tests, new patches, etc.) were not functional in the corresponding sandbox, the contributor should review them locally first, since they are likely to have issues.

## Pre-requirements

- VirtualBox and Vagrant locally installed.
- Host properly configured to use SSH and Git with OSM.
  - NOTE: In the case of a Windows host, this means:
    - Having your SSH keys (public and private in the `%userprofile%/.ssh` folder (the one equivalent to `~/.ssh` in Linux/Mac),
    - Having Git installed and properly configured in Windows, i.e. check that `%userprofile%/.gitconfig` exists and has the proper configuration.
      - In particular, it is required that the `user.name` there contains your EOL account name (i.e. avoid using a full name there). Beware that only the global profile is supported.

## Basic use of Vagrant

To build a sandbox from scratch:

```bash
cd folder_of_the_sandbox
vagrant up
```

NOTE: All the examples that follow are suppossed to be run in the same sandbox's folder.

To access the VM via SSH:

```bash
vagrant ssh
```

To destroy the VM:

```bash
vagrant destroy
```

To rebuild and reprovision the VM:

```bash
vagrant destroy && vagrant up
```
