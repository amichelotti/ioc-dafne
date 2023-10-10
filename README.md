Generic IOC Template Repository
===============================

This repository is a template for creating a generic IOC in the epics-containers
framework. See https://epics-containers.github.io for tutorials and documentation.

To use this repository:-

1.  Go to the
    [GitHub page](https://github.com/epics-containers/ioc-template) and
    click `Use this template` -> `Create a new repository` Then choose a name and
    organization for your new generic IOC.

1. Change the README.md file to describe your IOC.

1. Change the Dockerfile to compile in the support modules you need in
   your generic IOC Container.

1. You can run some basic tests to prove that the container loads and has
   the correct runtime libraries using the `tests/runtests.sh` script.
   This uses
   [epics-containers-cli](https://github.com/epics-containers/epics-containers-cli)
   which provides a command line interface
   for managing and deploying containerised IOCs.

1. Once you have it working you can update tests/runtests.sh to run your
   IOC in a container and test it. We recommend creating a Tickit simulation
   of the device you are controlling and using that to test your IOC.
   See https://dls-controls.github.io/tickit/typing_extensions/index.html


