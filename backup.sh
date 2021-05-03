#!/usr/bin/env bash
# This script needs the MEGA CMD application
HOSTNAME=$(hostname)
rootdir="backup"
encpasslen=64
passdir=".backpass"
passfile="$passdir/pass"
passchecksumfile="$passdir/pass.checksum"
backupdir="/home/$(whoami)"
backupfilename="$HOSTNAME_$(date +%s)"

# check password file integrity
sha512sum --check $passchecksumfile
if [[ $? != 0 ]]; then
  echo "password checksum file broken"
  exit 1
fi

echo "create backup file"
# openssl aes-256-cbc -in some_file.enc -out some_file.unenc -d -pass pass:somepassword
tar --exclude="$backupdir/Downloads" --exclude="$backupdir/MEGA" -cvjSf - $backupdir | openssl enc -e -aes256 -pass file:$passfile -out "/tmp/$backupfilename.tar.bz2.enc"
echo "finished creating backup file"

mega-put "/tmp/$backupfilename.tar.bz2.enc" "$rootdir/$HOSTNAME/"
