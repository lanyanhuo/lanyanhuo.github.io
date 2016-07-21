#!/bin/bash

template='---
layout: post
title: %%TITLE%%
categories:
  - Other
tags: [Other]
---

# %%TITLE%%
'

date=`date +%F`
edit_cmd="vim"

if [[ "$1" != "" ]];then
    title=$1
else
    echo
    echo "Usage:"
    echo "    $0 'blog title'"
    echo
    exit
fi

blog_file="_posts/$date-$title.md"

if test -f $blog_file ;then
    echo "$blog_file is existed!"

    echo "你要更新<<$title>>这篇博文吗? [y|n] (default: n)"
    read yn
    if [[ "$yn" == "y" ]];then
        vim $blog_file
    else
        exit
    fi
else
    echo -e "$template" > $blog_file
    sed -i 's/%%TITLE%%/'"$title"'/' $blog_file
    $edit_cmd $blog_file
fi
