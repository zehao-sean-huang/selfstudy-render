# Choose anaconda3 as base image
FROM ubuntu:18.04

# Build blender python module

# Build Tools
RUN apt-get update
RUN apt-get install -y build-essential git subversion cmake libx11-dev libxxf86vm-dev libxcursor-dev libxi-dev libxrandr-dev libxinerama-dev libglew-dev python3 sudo

# Set up directories
RUN mkdir /blender-git

# Source Code and Checkout 2.8
RUN cd /blender-git/ && git clone https://git.blender.org/blender.git

# Checkout to blender 2.80
RUN cd /blender-git/blender && git checkout tags/v2.80

# Git submodules
RUN cd /blender-git/blender && git submodule update --init --recursive
RUN cd /blender-git/blender && git submodule foreach git checkout master
RUN cd /blender-git/blender && git submodule foreach git pull --rebase origin master

# Download Libraries
RUN mkdir /blender-git/lib
RUN cd /blender-git/lib && svn checkout https://svn.blender.org/svnroot/bf-blender/trunk/lib/linux_centos7_x86_64

# Dependencies
RUN cd /blender-git/blender && ./build_files/build_environment/install_deps.sh

# Update and build
RUN cd /blender-git/blender && make bpy

# Move the built files to python
RUN mv /usr/local/PYTHON_SITE_PACKAGES-NOTFOUND/ /blender-git/bin

# Anaconda installing
RUN wget https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
RUN bash Anaconda3-2019.10-Linux-x86_64.sh -b
RUN rm Anaconda3-2019.10-Linux-x86_64.sh

# PATH
ENV PATH /root/anaconda3/bin:$PATH

# Copy binaries to Anaconda site-packages
RUN cp /blender-git/bin/bpy.so /root/anaconda3/lib/python3.7/site-packages/
RUN cp -r /blender-git/bin/2.80 /root/anaconda3/lib/python3.7/site-packages/2.80/

# Remove Build Files
RUN rm -rf /blender-git/
RUN rm -rf /root/src/

