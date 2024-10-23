FROM archlinux:latest

# Install essential packages
RUN pacman -Syu --noconfirm \
  base-devel \
  cmake \
  wget \
  git \
  doxygen \
  && pacman -Scc --noconfirm 

ENV ZIG_VERSION 0.13.0
RUN wget https://ziglang.org/download/$ZIG_VERSION/zig-linux-x86_64-$ZIG_VERSION.tar.xz \
  && tar -xf zig-linux-x86_64-$ZIG_VERSION.tar.xz \
  && mv zig-linux-x86_64-$ZIG_VERSION /usr/local/zig \
  && ln -s /usr/local/zig/zig /usr/local/bin/zig

WORKDIR /app
COPY . .
