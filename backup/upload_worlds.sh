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

    # delete the old data
    ssh $line "sudo rm -rf /home/core/minecraft-data"

    # make the folder again
    ssh $line "mkdir -p /home/core/minecraft-data"

    # upload the world
    scp -r ./worlds/$hostname/* $line:/home/core/minecraft-data

    # change the permissions
    ssh $line "sudo chown -R 1000:1000 /home/core/minecraft-data"
    ssh $line "sudo chmod -R 755 /home/core/minecraft-data"

    # start the minecraft server
    ssh $line "sudo systemctl start minecraft && sudo systemctl enable minecraft"
done < "$file"