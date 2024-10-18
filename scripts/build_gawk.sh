#!/bin/bash

BINKIT_ROOT="target/gawk"

rm -rf target && mkdir -p target

cd target

wget https://ftp.gnu.org/gnu/gawk/gawk-5.2.1.tar.gz
tar -xvf gawk-5.2.1.tar.gz
mv gawk-5.2.1 gawk

# EOF
