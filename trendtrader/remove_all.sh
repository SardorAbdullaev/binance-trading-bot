#!/usr/bin/env bash
for i in supported_coin_list*; do
    [ -f "$i" ] || break
    suffix="${i/supported_coin_list/}"
    docker stack rm $suffix
done

