# Modelica In Action

This repository contains examples that demonstrate how to
create, compile and simulate Modelica models using [JModelica](http://www.jmodelica.org).

## Installation

In order to simplify your life the repository contains all the code
necessary to create a [Docker](https://www.docker.com) container that runs JModelica.
In case you wonder what's a Docker container

> Docker containers wrap a piece of software in a complete filesystem that contains
> everything needed to run: code, runtime,   system tools, system libraries – anything
> that can be installed on a server. This guarantees that the software will always
> run the same, regardless of its environment (see https://www.docker.com/what-docker
> for more info).

In this case I created a "recipe", also known as [Docker file](https://github.com/mbonvini/ModelicaInAction/blob/master/docker/Dockerfile),
that describes how to build a container with installed everything that's needed
to work with JModelica.

Once created and started, the container and your computer will interact as shown
in the following image.

![alt tag](https://github.com/mbonvini/ModelicaInAction/blob/master/images/container_scheme.png)

Upon start, some folders included in this repository will be shared with the container,
in the meantime the container runs an IPython server. The container exposes the port
used by the IPython server to your local machine. In this way you can connect to the
IPython server in the container with a browser. Once you access the IPython
server you can start working with JModelica.

The Docker container is based on a so called image (something similar to a snapshot
of a virtual machine). To create the image you have two options

 * manually build the image with the command
 `make build-image`
 
 * download the image with the command
 `make download-image`
 
The second option is preferable because it doesn't require you to wait while Docker
compiles from source JModelica and all its dependencies. 
