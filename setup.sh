#!/bin/bash

# download nvim config
git submodule init
git submodule update --recursive --remote
git submodule foreach --recursive '
    git checkout $(git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@") ||
    git checkout main ||
    git checkout master
'

# create symlinks of my dotfiles (will not override if already exists)
[ -d "$HOME/.config" ] && ln -s $HOME/dotfiles/.config/* $HOME/.config || ln -s $HOME/dotfiles/.config $HOME