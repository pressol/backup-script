#!/usr/bin/env bash
# This script will setup megacmd login and the backup directories
# The mega login part assumes that you have 2fa enabled. If you don't you should.

if [[ $0 == "help" ]]; then
  echo  "
  You need to pass parameters in this order
  0 - 2fa code
  1 - email
  2 - password plain text
  3 - this should either be yes or no. This will enforce https if answered yes
  "
  exit 0
fi

HOSTNAME=$(hostname)
rootdir="backup"
encpasslen=64
passdir=".backpass"

FACODE=$0
email=$1
password=$2
usehttps=$3

if [[ $usehttps == "yes" ]]; then
  mega-https on
fi

# login [--auth-code=XXXX] email password
mega-login --auth-code $0 $1 $2
if [[ $? != 0 ]]; then
  echo "something went wrong when you logged in"
  exit 1
fi

mega-mkdir -p "$rootdir/$HOSTNAME/"
if [[ $? != 0 ]]; then
  echo "something went wrong when you created the backup dir"
  exit 1
fi

# create encryption password
mkdir $passdir
touch "$passdir/pass"
openssl rand -base64 $encpasslen | tee "$passdir/pass"
sha512sum "$passdir/pass" | tee "$passdir/pass.checksum"

# creating empty exlude file
touch "$passdir/exclude.txt"
