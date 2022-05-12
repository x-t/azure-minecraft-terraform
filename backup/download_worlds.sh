#!/usr/bin/env bash

set -ex

file="hosts"

while IFS= read -r line; do
    # skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    # get hostname through ssh
    hostname=$(ssh $line hostname)

    # stop the minecraft server
    ssh $line "sudo systemctl stop minecraft && sudo systemctl disable minecraft"

    # remove the old backup
    rm -rf ./worlds/$hostname

    # download the world
    scp -r $line:/home/core/minecraft-data/ ./worlds/$hostname

    # start the minecraft server
    ssh $line "sudo systemctl start minecraft && sudo systemctl enable minecraft"
done < "$file"