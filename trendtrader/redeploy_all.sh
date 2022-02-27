#!/usr/bin/env bash
for i in supported_coin_list*; do
    [ -f "$i" ] || break
    suffix="${i/supported_coin_list/}"
    docker_file_name=docker-stack${suffix}.yml
    apprise=apprise${suffix}.yml
    cfg=user${suffix}.cfg
    cp docker-stack.yml $docker_file_name
    cp config/apprise.yml config/${apprise}
#    cp .user.cfg.example $cfg
    sed -i.bak 's/supported_coin_list:/'${i}':/g' $docker_file_name
    rm -f *.bak
    sed -i.bak 's/apprise.yml:/'${apprise}':/g' $docker_file_name
    rm -f *.bak
#    sed -i.bak 's/user.cfg:/'${cfg}':/g' $docker_file_name
#    rm -f *.bak
    docker stack deploy --compose-file $docker_file_name ${i/supported_coin_list_/}
done

