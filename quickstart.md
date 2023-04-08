# Quickstart Guide

If you want to quickly set up the environment and try out this gem then you can follow these steps.

```bash
docker run -it --name ffi_gen ubuntu bash
# continue in the container

# prepare container
apt update
apt install build-essential
apt install wget

# install llvm
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh 15 all
# install the packages it suggests then run again

# install ruby
apt install ruby ruby-dev
gem install bundler

# install gem
gem install ffi_gen

# you can try using ffi_gen now

# for running tests
apt install libcairo-dev

````
