Generic IOC Template Repository
===============================

This repository is a template for creating a generic IOC in the epics-containers
framework. See https://epics-containers.github.io for tutorials and documentation.

Making a new generic IOC
------------------------

1.  Go to the
    [GitHub page](https://github.com/epics-containers/ioc-template) and
    click **Use this template** -> **Create a new repository** Then choose a name and
    organization for your new generic IOC.

1. Change the `README.md` file to describe your IOC.

1. Change the `Dockerfile` to compile in the support modules you need in
   your generic IOC Container.

1. Once you have it working you can update `tests/runtests.sh` to run your
   IOC in a container and test it. We recommend creating a Tickit simulation
   of the device you are controlling and using that to test your IOC.
   See https://dls-controls.github.io/tickit/typing_extensions/index.html


Working with the IOC
--------------------

1. A generic IOC with a working Dockerfile can be built with the build script
   in the root folder. This builds runtime and developer targets. This must be
   run outside the dev container.

1. Pushing the repo to github and tagging it will release a container image
   to the GitHub container registry. Gitlab CI is also supported.

1. Launching the project in vscode or other devcontainer IDE will allow you
   to open a devcontainre and test the IOC locally (including IOCs with
   system dependencies not available on your host).

1. A Basic test that verifies you have the correct libraries installed in
   the runtime container is provided in tests/runtests.sh. This must be
   run outside the dev container.

Developing inside the devcontainer
----------------------------------

A few points to note when developing inside the devcontainer:

1. The project folder is mounted at `/epics/ioc-template` (or equivalent).
   This means that the devcontainer container correleates closely to how
   the rutime container looks. Because of this you will have an uncompiled
   IOC when you first open the devcontainer. The following command  will
   make a working IOC:

   - `ibek ioc build`

      - adds a templated ioc source tree to `/epics/ioc-template/ioc`
      - generates a `Makefile` that includes all the dbds and libs from the
         support moudules in the container
      - compiles the resulting IOC


1. The ibek tool is preinstalled in the devcontainer. It is used by Dockerfiles
   to build the IOC but you can also use it on the command line. See
   `ibek --help` for more information.

1. You can add additional projects to your workspace that are peers to the
   `ioc-template` project. The folder `/repos` is mounted to the parent of
   your project folder for this purpose.

1. You can customize bash configuration and also customize a profile that can
   install additional packages at devcontainer creation time. These are
   customizations are for developer personalization and can apply to all
   epics-containes ioc projects. See [README.md](user_examples/README.md).
