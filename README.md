# Docker Toolchain of the Bethge Lab

This repository includes utilities to build and run the Docker images of the [Bethge Lab](http://bethgelab.org/). The toolchain is composed of four different images (more details below):

* The __xserver__ image adds user-authentication and Xserver capabilities to a base Ubuntu-image. In particular, this images fixes a file permission problem: new files created from within the container are owned by root and thus conflict with user permissions.

* The __jupyter-notebook__ image is a fork of the official [jupyter/notebook image](https://hub.docker.com/r/jupyter/notebook/) but is based on xserver.

* The __jupyter-scipyserver__ image is based on jupyter-notebook and adds many python packages needed for scientific computing such as Numpy and Scipy (both compiled against OpenBlas), Theano, Lasagne, Pandas, Seaborn and more.

* The __jupyter-deeplearning__ image is based on jupyter-scipyserver (including Lasagne) but adds some libraries such as Caffe, Torch, Keras, Scikit-image, Joblib and others. Tensorflow will follow as soon as CuDNN v4 is supported.

All images come with different (or no) CUDA-libraries installed. Currently we support plain __Ubuntu 14.04__, __Ubuntu 14.04 + Cuda 6.5__ or __Ubuntu 14.04 + Cuda 7.0 + CuDNN v2, v3 or v4__. All images are readily available from [Docker Hub](https://hub.docker.com/u/bethgelab/) and the names are structured according to

    bethgelab/image:tag

so, e.g. to pull the image *jupyter-deeplearning* with Cuda 7.0 and CuDNN v3 you would do

    docker pull bethgelab/jupyter-deeplearning:cuda7.0-cudnn3

Available tags are *ubuntu-14.04*, *cuda6.5*, *cuda7.0-cudnn2*, *cuda7.0-cudnn3* and *cuda7.0-cudnn4*.

### AGMB Docker wrapper

To make the employment of the containers as painless as possible we have wrapped all important flags in the script ```agmb-docker``` (see root directory of repo), which is a modification of the ```nvidia-docker``` wrapper from the [nvidia-docker repository](https://github.com/NVIDIA/nvidia-docker). To run a container, first pull the image from Docker Hub (important - otherwise the CUDA version cannot be detected) before running the command

    GPU=0 ./agmb-docker run -d bethgelab/jupyter-deeplearning:cuda7.0-cudnn3

or equivalently for any other image or tag. This command has to be run in the folder in which the agmb-docker script was placed. The script takes care of setting up the NVIDIA host driver environment inside the Docker container, adds the current user, mounts his home-directory in which it finally starts the jupyter notebook. Some properties are specific to users within the AG Bethge lab, but as an external user one can override all settings. As the most stripped-down version, use

    GPU=0 ./agmb-docker run -e GROUPS=sudo -e USER_HOME=$HOME -d bethgelab/jupyter-deeplearning:cuda7.0-cudnn3

Note that all the usual docker flags can be given. In addition, some environmental variables have a special meaning

* ```USER```  --  The username that is added to the container
* ```USER_ID```  --  The user ID for the new user
* ```USER_GROUPS```  --  The groups to which the user is added (default: sudo,bethgelab:1011,cin:1019); the first group will act as the primary group
* ```USER_ENCRYPTED_PASSWORD```  --  your user password (encrypted). To generate it: ```perl -e 'print crypt('"PASSWORD"', "aa"),"\n"' ```

GPUs are exported through a list of comma-separated IDs using the environment variable ```GPU```.
The numbering is the same as reported by ```nvidia-smi``` or when running CUDA code with ```CUDA_DEVICE_ORDER=PCI_BUS_ID```, it is however **different** from the default CUDA ordering.

## xserver: LDAP, Xserver & OpenBLAS

This image is a modification and extension of a Dockerfile by [Alexander Ecker](https://github.com/aecker/docker). It enables the following features:

1. Using LDAP user within a Docker container (more precisely: emulates it by using a local user with the same uid).
2. Runs an X server.
3. SSH daemon, i.e. allows `ssh -X` to run GUI within the Docker container.
4. Installs OpenBLAS.

Note that one should not override the `CMD` in this image. If you need to execute additional programs when starting the container, add them to `/usr/local/bin/startup` as follows:

`RUN echo "./mycmd" >> /usr/local/bin/startup`

## jupyter-notebook

This image is a fork of the official [jupyter/notebook image](https://hub.docker.com/r/jupyter/notebook/) with some modifications to allow a shift of the base image from plain Ubuntu to our CUDA-enhanced ldap-xserver images. The Jupyter Notebook runs as the User and listens to port 8888. At runtime the container will initialize (and display) a port-forwarding between host and container, the choice can be overriden by setting the forward manually, e.g.

    GPU=0 ./agmb-docker run -p 534:8888 -d bethgelab/jupyter-deeplearning:cuda7.0-cudnn3

The notebook can then be reached by

    http://localhost:534

By default the notebook will start from user home.

## jupyter-scipyserver

This image is based on jupyter-notebook and adds the following packages to both Python 2.7 and Python 3.4:

* Numpy (compiled against OpenBLAS)
* Scipy (compiled against OpenBLAS)
* pandas
* scikit-learn
* matplotlib
* seaborn
* h5py
* yt
* sympy
* patsy
* ggplot
* statsmodels
* Theano (from master)
* Lasagne (from master)
* Bokeh
* mock
* pytest

## jupyter-deeplearning

This image is based on jupyter-scipyserver and adds Caffe 0.14 (binaries by NVIDIA) as well as Torch and iTorch. In addition, the following packages are installed for Python 2.7:

* scikit-image
* h5py
* leveldb
* networkx
* joblib
* bloscpack
* keras

# Issues and Contributing
* Please let us know by [filing a new issue](https://github.com/bethgelab/docker/issues/new)
* You can contribute by opening a [pull request](https://help.github.com/articles/using-pull-requests/)
