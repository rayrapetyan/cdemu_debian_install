# Building and installing `cdemu` for Debian using Docker

In this tutorial, I'll walk you through the process of building and installing `cdemu` on Debian using Docker. 
`cdemu` is a virtual CD/DVD drive emulator for Linux that allows you to mount and manage disc images.

## Prerequisites

Before you begin, ensure that you have the following prerequisites:

- Docker installed on your Debian system.
- Git installed to clone the `cdemu` repository.

## Step 1: Clone the `cdemu` Repository

First, clone the original `cdemu` repository from GitHub using the following command:

    git clone https://github.com/cdemu/cdemu.git

This will create a local copy of the `cdemu` repository on your system.

## Step 2: Obtain Your Debian Version Codename

To build the `cdemu` package, you need to know the codename of your Debian distribution. To find it, open a terminal and 
run the following command:

    lsb_release -cs

Note down the codename as you'll need it in the next step.

## Step 3: Copy the Dockerfile and Build the Docker Image

Copy the provided Dockerfile into the cloned `cdemu` folder. Then, open the Dockerfile in a text editor and update the 
builder base image's codename (first line in the Dockerfile) with the one you obtained in Step 2.

Navigate to the `cdemu` folder in the terminal and build the Docker image using the following command:

    docker build --progress=plain -t cdemu:dev .

This command will create a Docker image with the `cdemu` Debian packages (deb-files).

## Step 4: Copy `cdemu` deb files to Your Local Machine

Next, copy the `cdemu` deb files from the Docker image to your local machine. Perform the following steps:

    docker run -d --name=cdemu cdemu:dev
    docker start cdemu
    rm -rf ./build
    docker cp cdemu:/build/ ./build

The `cdemu` deb files are now copied into the ./build folder on your local machine.

## Step 5: Install `cdemu` deb Packages

To install `cdemu` on your system use the following command:

    sudo apt install ./build/*.deb

This command will install all the required `cdemu` packages on your Debian system.

## Step 6: Run the `cdemu` GUI

With `cdemu` installed, you can now run the `gcdemu` command to open the graphical user interface (GUI) for managing 
virtual CD/DVD drives:

    gcdemu

You're all set! You have successfully built and installed `cdemu` on your Debian system using Docker. Now you can use 
`gcdemu` to mount and manage disc images with ease. Enjoy using `cdemu` for a seamless virtual disc experience!
