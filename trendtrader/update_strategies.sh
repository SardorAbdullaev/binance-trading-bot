#!/usr/bin/env bash
for i in supported_coin_list*; do
    [ -f "$i" ] || break
    suffix="${i/supported_coin_list/}"
    cfg=user${suffix}.cfg
#    cp .user.cfg.example $cfg
    sed -i.bak 's/strategy='${1}'/strategy='${2}'/g' $cfg
    rm -f *.bak
done

