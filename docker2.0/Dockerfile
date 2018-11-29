# Author: Marco Bonvini
# email: bonvini.m@gmail.com
#
FROM ubuntu:18.04

MAINTAINER MarcoBonvini bonvini.m@gmail.com

# Avoid interaction
ENV DEBIAN_FRONTEND noninteractive

# =========== Basic Configuration ======================================================
# Update the system
RUN apt-get -y update \
    && apt-get install -y sudo build-essential git python python-dev \
    python-setuptools make g++ cmake gfortran ipython swig ant python-numpy \
    python-scipy python-matplotlib cython python-lxml python-nose python-jpype \
    libboost-dev jcc git subversion wget zlib1g-dev pkg-config clang

# ========== Install pip for managing python packages ==================================
RUN apt-get install -y python-pip python-lxml && pip install cython

# ========== Create an user and environmental variables associated to it ===============
RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# ========= Add folders that will contains code before and after installation ==========
RUN mkdir -p /home/docker/to_install \
    && mkdir -p /home/docker/installed/Ipopt

# ========= Install JAVA ===============================================================
RUN apt-get install -y openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

# Define JAVA_HOME envirponmental variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /root/.bashrc \
    &&  echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/docker/.bashrc

# ======== Install BLAS and LAPACK =====================================================
RUN  apt-get -y update \
   && apt-get install -y apt-utils \
   && apt-get install -y libblas-dev liblapack-dev

# ======== Install numpy, scipy, Matplotlib ============================================
RUN apt-get install -y pkgconf libpng-dev libfreetype6-dev \
    && pip install numpy \
    && apt-get install -y python-matplotlib \
    && pip install scipy

# ======== Start IPOPT installation ====================================================
# Retrieve and copy all the dependencies needed by Ipopt
WORKDIR /home/docker/to_install/Ipopt
RUN wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.4.tgz
RUN tar xvf ./Ipopt-3.12.4.tgz
WORKDIR /home/docker/to_install/Ipopt/Ipopt-3.12.4/ThirdParty/Blas
RUN ./get.Blas
WORKDIR /home/docker/to_install/Ipopt/Ipopt-3.12.4/ThirdParty/Lapack
RUN ./get.Lapack
WORKDIR /home/docker/to_install/Ipopt/Ipopt-3.12.4/ThirdParty/Mumps
RUN ./get.Mumps
WORKDIR /home/docker/to_install/Ipopt/Ipopt-3.12.4/ThirdParty/Metis
RUN ./get.Metis

# Configure and compile Ipopt
WORKDIR /home/docker/to_install/Ipopt/Ipopt-3.12.4/
RUN mkdir build
WORKDIR /home/docker/to_install/Ipopt/Ipopt-3.12.4/build
RUN ../configure --prefix=/home/docker/installed/Ipopt \
    && make \
    && make install

# ======== Start JModelica.org installation ===========================================0

# Intall autoconf which is called by the casADi installation
RUN apt-get install -y autoconf

# Checkout the JModelica.org source code
RUN mkdir -p /home/docker/installed/JModelica

# Thanks to Marcus Fuchs
# https://github.com/mbonvini/ModelicaInAction/pull/4/commits/1220d7c680957943bc17ad55ff009488d0887ce0
# This needs a nasty hack for more modern versions, since assimulo does not fit in svn ...
WORKDIR /home/docker/to_install
RUN svn co https://svn.jmodelica.org/trunk JModelica.org; exit 0 # <- hack
WORKDIR /home/docker/to_install/JModelica.org/external
RUN svn co https://svn.jmodelica.org/assimulo/trunk Assimulo # Checkout the lib manually

WORKDIR /home/docker/to_install/JModelica.org
RUN mkdir build
WORKDIR /home/docker/to_install/JModelica.org/build
RUN ../configure --prefix=/home/docker/installed/JModelica \
             --with-ipopt=/home/docker/installed/Ipopt
RUN make \
    && make install \
    && make install_casadi

# Define the environmental variables needed by JModelica
# JModelica.org supports the following environment variables:
#
# - JMODELICA_HOME containing the path to the JModelica.org installation
#   directory (again, without spaces or ~ in the path).
# - PYTHONPATH containing the path to the directory $JMODELICA_HOME/Python.
# - JAVA_HOME containing the path to a Java JRE or SDK installation.
# - IPOPT_HOME containing the path to an Ipopt installation directory.
# - LD_LIBRARY_PATH containing the path to the $IPOPT_HOME/lib directory
#   (Linux only.)
# - MODELICAPATH containing a sequence of paths representing directories
#   where Modelica libraries are located, separated by colons.
ENV JMODELICA_HOME /home/docker/installed/JModelica
ENV IPOPT_HOME /home/docker/installed/Ipopt
ENV CPPAD_HOME /home/docker/installed/JModelica/ThirdParty/CppAD/
ENV SUNDIALS_HOME /home/docker/installed/JModelica/ThirdParty/Sundials
ENV PYTHONPATH /home/docker/installed/JModelica/Python/:
ENV LD_LIBRARY_PATH /home/docker/installed/Ipopt/lib/:\
/home/docker/installed/JModelica/ThirdParty/Sundials/lib:\
/home/docker/installed/JModelica/ThirdParty/CasADi/lib
ENV SEPARATE_PROCESS_JVM /usr/lib/jvm/java-8-openjdk-amd64/
ENV MODELICAPATH /home/docker/installed/JModelica/ThirdParty/MSL:/home/docker/modelica

# ============ Expose ports ============================================================
EXPOSE 8888

# ============ Install IPython/Jupyter notebook ========================================
RUN apt-get install -y ipython
RUN pip install jupyter

# ============ Set Jupyter password ====================================================
RUN mkdir -p /home/docker/.jupyter && jupyter notebook --generate-config
RUN python -c 'import json; from notebook.auth import passwd; open("/home/docker/.jupyter/jupyter_notebook_config.json", "w").write(json.dumps({"NotebookApp":{"password": passwd("modelicainaction")}}));'

# ============ Set some environmental vars and change user =============================
USER docker
RUN mkdir /home/docker/modelica && mkdir /home/docker/ipynotebooks
ENV USER docker
ENV DISPLAY :0.0
WORKDIR /home/docker/
