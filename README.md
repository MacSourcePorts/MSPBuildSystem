# MSPBuildSystem
Mac Source Ports Build System

This repo contains the Mac Source Ports build system files. As much as possible I'm trying to break away from using MSP-specific forks and instead use the original project's code, this makes it easier to incorporate their latest code and release strategies. 

The table below is a representation of the migration process. 


|         Source Port         | Migrated | Uses Project's Repo | Uses MacSourcePorts Fork | Versioning Strategy                          |                                      Notes                                      |
|:---------------------------:|:--------:|:-------------------:|:------------------------:|----------------------------------------------|:-------------------------------------------------------------------------------:|
| ArxLibertatis               | ☑️        | ☑️                   |                          | Versioned project tags                       |                                                                                 |
| augustus                    | ☑️        | ☑️                   |                          | Versioned project tags                       |                                                                                 |
| CorsixTH                    | ☑️        | ☑️                   |                          | Versioned project tags, separate arch builds |                                                                                 |
| DevilutionX                 | ☑️        | ☑️                   |                          | Versioned project tags                       |                                                                                 |
| dhewm3                      | ☑️        |                     | ☑️                        | Latest code from our fork                    | Need to do a PR to get some Mac code in                                         |
| disasteroids3d              | ☑️        |                     | ☑️                        | Latest code                                  | This one is fine to leave as our fork. It is rarely going to change             |
| DXX-Rebirth                 | ☑️        | ☑️                   |                          | Latest code                                  | Project does use tags, but not since 2018                                       |
| ECWolf                      | ☑️        |                     | ☑️                        | Latest code                                  | Uses bitucket. Project does not do version tags                                 |
| EDuke32                     | ☑️        |                     | ☑️                        | See note                                     | This project is maintained on a hosted GitLab thing at Voidpoint.io. The latest code, last I checked, will not build on Mac. So the MSP fork is the most recent thing that will. For now this works.                                                                                 |
| GemRB                       | ☑️        |                     |                          | Latest code                                  | Most recent tag has build issues on macOS, going with latest until next release |
| ioquake3                    | ☑️        |                     | ☑️                        | Latest code                                  | Build script scrapes version number from Makefile, but it's almost always 1.36. I need to do a PR for the proper separated Universal 1 and Universal 2 builds|
| iortcw                      | ☑️        |                     | ☑️                        | Latest code                                  | Parent project has some automatic support for Apple Silicon, I need to do a PR with the rest                                                                                |
| jk2mv                       | ☑️        |                     | ☑️                        | Latest code                                  | Project does use tags, but not since 2018. Should do PR for Apple Silicon support. Also there's two repos since one is a submodule of the other.                                                                                 |
| julius                      | ☑️        | ☑️                   |                          | Versioned project tags                       |                                                                                 |
| Maelstrom                   | ☑️        |                     | ☑️                        | Latest code                                  | This one is fine to leave as our fork. It will rarely change                    |
| OpenJK/OpenJO               |          |                     |                          |                                              |                                                                                 |
| OpenJKDF2                   | ☑️        |                     | ☑️                        | Versioned project tags                       | This one needs some attention before I can try and use the project's repo       |
| OpenRCT2                    |          |                     |                          |                                              |                                                                                 |
| OpenTyrian                  |          |                     |                          |                                              |                                                                                 |
| OpenTyrian2000              |          |                     |                          |                                              |                                                                                 |
| OpenXcom                    | ☑️        | ☑️                   |                          | Latest code                                  | Project does use tags, but not since 2014                                       |
| RBDOOM-3-BFG                |          |                     |                          |                                              |                                                                                 |
| Serious-Engine (INCOMPLETE) |          |                     |                          |                                              |                                                                                 |
| rottexpr                    |          |                     |                          |                                              |                                                                                 |
| shockolate                  |          |                     |                          |                                              |                                                                                 |
| The Ur-Quan Masters         |          |                     |                          |                                              |                                                                                 |
| vkQuake                     |          |                     |                          |                                              |                                                                                 |
| yquake2                     | ☑️        | ☑️                   |                          | Versioned project tags                       |                                                                                 |
