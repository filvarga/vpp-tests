#!/bin/bash
dest=/tmp
/usr/bin/gzip -1 > "${dest}/core.${1}.gz.`date -d @${2} +'%Y.%m.%d-%H.%M.%S'`"
