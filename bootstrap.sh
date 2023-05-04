#!/usr/bin/env bash

echo git user.name
read git_user_name

echo git email
read git_email

echo "Installing xcode..."
xcode-select --install

if !(command -v brew >/dev/null 2>&1); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew tap homebrew/cask-versions
  brew bundle
else
  echo "Homebrew already installed."
fi

echo "Updating homebrew..."
brew update

if !(command -v brew >/dev/null 2>&1); then
  echo "Installing fish shell..."
  brew install fish
  curl -L https://get.oh-my.fish | fish
  sudo bash -c 'echo $(which fish) >> /etc/shells'
  chsh -s $(which fish)
else
  echo "Fish shell already installed."
fi

if [ "$git_user_name" != "" ] && [ "$git_email" != "" ]; then
  echo "Git config..."
  git config --global user.name $git_user_name
  git config --global user.email $git_email
else
  echo "Skipping git config."
fi

if !(command -v emacs >/dev/null 2>&1); then
  echo "Installing emacs..."
  brew tap railwaycat/emacsmacport
  brew install emacs-mac --with-modules
  ln -s /usr/local/opt/emacs-mac/Emacs.app /Applications/Emacs.app

  git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
  ~/.config/emacs/bin/doom install

  git clone https://github.com/cpnat/.doom.d ~/.config/doom
  doom sync
else
  echo "Emacs already installed."
fi

if !(brew list pyenv-virtualenv &>/dev/null); then
  echo "Setting up Python ..."
  brew_install pyenv-virtualenv
  set -Ux PYENV_ROOT $HOME/.pyenv
  fish_add_path $PYENV_ROOT/bin
  pyenv init - | source >> ~/.config/fish/config.fish
else
  echo "Python already installed."
fi

echo "Installing dependencies from Brewfile..."
brew bundle
