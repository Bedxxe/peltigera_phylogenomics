#!/usr/bin/env bash

awk -v OFS='\t' '
    {
        if ( /^>/ ) { out = (NR>1 ? ORS : "") substr($0,2) OFS }
        else        { out = $0 }
        printf "%s", out
    }
    END { print "" }
' "${@:--}"