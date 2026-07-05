# Ember Homebrew Tap

Homebrew packages for [Ember](https://github.com/kingb/ember), a native
terminal emulator built from scratch in Rust for macOS and Linux.

## Install

macOS (a signed, notarized app bundle, no Gatekeeper warning):

    brew install --cask kingb/ember/ember

Linux (built from source via cargo, a from-source build takes a few minutes):

    brew install kingb/ember/ember

Homebrew maps `kingb/ember` to this `homebrew-ember` tap.

## Upgrade

    brew upgrade --cask ember      # macOS
    brew upgrade ember              # Linux
