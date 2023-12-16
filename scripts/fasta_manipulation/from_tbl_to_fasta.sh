#!/usr/bin/env bash

awk -F'\t' '
    {
        gsub(/.{60}/,"&"ORS,$2)
        sub(ORS"$","",$2)
        print ">" $1 ORS $2
    }
' "${@:--}"
