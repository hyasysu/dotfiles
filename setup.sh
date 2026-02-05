#!/bin/bash

# create symlinks of my dotfiles (will not override if already exists)
[ -d "$HOME/.config" ] && ln -s $HOME/dotfiles/.config/* $HOME/.config || ln -s $HOME/dotfiles/.config $HOME