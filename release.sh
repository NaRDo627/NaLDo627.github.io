#!/bin/bash

# ASSERT: args
if [ $# -ne 1 ]; then
    echo "usage: release.sh TITLE"
    echo "       ex) release.sh working-with-draft"
    exit $E_BADARGS
fi

function addExt() {
    FILE=$1
    if [[ ${FILE: -3} == ".md" ]]; then
        echo $1
    elif [[ ${FILE: -9} == ".markdown" ]]; then
        echo $1
    else
        echo $1.md
    fi
}

# constants
ROOT=../NaLDo627.github.io
SRC_PATH=${ROOT}/_drafts
DST_PATH=${ROOT}/_posts

DRAFT=draft.md
TITLE=$1
TITLE=`addExt ${TITLE}`

if [ ! -f ${SRC_PATH}/${DRAFT} ]; then
    echo "File ${SRC_PATH}/${DRAFT} is not exist"
fi

TODAY=`date +"%Y-%m-%d"`

#cp ${SRC_PATH}/${TITLE} ${DST_PATH}/${TODAY}-${TITLE}
cp ${SRC_PATH}/${DRAFT} ${DST_PATH}/${TODAY}-${TITLE}

TODAY_STR=`date +"%Y-%m-%d %H:%M:%S +0900"`
sed -i "5s/.*/date : ${TODAY_STR}/g" ${DST_PATH}/${TODAY}-${TITLE}

echo "Draft ${TITLE} is moved to ${DST_PATH}/${TODAY}-${TITLE}"
