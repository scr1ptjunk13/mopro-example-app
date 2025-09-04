# complete mopro setup guide

## prerequisites installation

```sh
# install rust and basic tools
sudo pacman -S rustup base-devel cmake gcc git openmp clang nasm libc++ libc++abi

# setup rust
rustup install stable
rustup default stable
```

## install android ndk (required for android builds)

```sh
# install android ndk via aur (easiest method)
yay -S android-ndk
# OR if you use paru:
# paru -S android-ndk

# set environment variable
export ANDROID_NDK=/opt/android-ndk
echo 'export ANDROID_NDK=/opt/android-ndk' >> ~/.bashrc
```

## clone and build mopro

```sh
# clone mopro
git clone https://github.com/zkmopro/mopro.git
cd mopro

# build mopro with proper environment
export CC=clang
export CXX=clang++
export LDFLAGS="-L/usr/lib -lomp"
cargo build --release
```

## setup environment variables

```sh
# add mopro to path and set library paths
echo 'export PATH="$HOME/mopro/target/release:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="$HOME/mopro/target/release/build/rust-rapidsnark-7c60869e99a706fa/out/rapidsnark/x86_64:$HOME/mopro/target/release/build/rust-rapidsnark-12150980dfd0f90a/out/rapidsnark/x86_64:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export ANDROID_NDK=/opt/android-ndk' >> ~/.bashrc

# reload shell
source ~/.bashrc
```

## test installation

```sh
# verify mopro works
mopro --help
```

## create your first project

```sh
# create a project directory
mkdir ~/my-zk-project
cd ~/my-zk-project

# initialize mopro project
mopro init
# choose: noir (use spacebar to select, enter to confirm)

# navigate to project
cd mopro-example-app

# build the project
mopro build
# choose: debug
# choose: android
# choose: aarch64-linux-android (use spacebar to select)
```

## quick troubleshooting

if `mopro: command not found`:
```sh
export PATH="$HOME/mopro/target/release:$PATH"
```

if `librapidsnark.so not found`:
```sh
export LD_LIBRARY_PATH="$HOME/mopro/target/release/build/rust-rapidsnark-7c60869e99a706fa/out/rapidsnark/x86_64:$HOME/mopro/target/release/build/rust-rapidsnark-12150980dfd0f90a/out/rapidsnark/x86_64:$LD_LIBRARY_PATH"
```

if `ANDROID_NDK not set`:
```sh
export ANDROID_NDK=/opt/android-ndk
```

## alternative platforms

if you don't want android, when running `mopro build`, you can choose:
- ios (requires macos)
- web (for webassembly)
- skip platform selection for rust-only builds

## notes

- build time: ~10-15 minutes for release build
- use debug mode for faster builds during development
- use aarch64-linux-android for modern android devices
- the setup adds everything to your ~/.bashrc for permanent use

## after setup

your mopro is ready! you can now:
- create zero-knowledge circuits with noir
- generate proofs
- build for android/web platforms
- integrate zk proofs into mobile apps
