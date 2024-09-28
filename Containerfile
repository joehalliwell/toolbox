FROM quay.io/toolbx-images/archlinux-toolbox:latest

LABEL name="toolbox"
LABEL maintainer="Joe Halliwell <joe.halliwell@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/joehalliwell/toolbox"
LABEL org.opencontainers.image.description="Personal toolbox"
LABEL com.github.containers.toolbox="true"

# Install keys
RUN pacman-key --init
RUN pacman -Sy --noconfirm archlinux-keyring

# Install packages
COPY packages.txt /
RUN pacman -Syu --needed --noconfirm $(grep -v "^#" packages.txt)
RUN rm /packages.txt

# Build and install paru for working with AUR
RUN useradd -m paru
USER paru
RUN git clone https://aur.archlinux.org/paru-bin.git /tmp/paru && \
    cd /tmp/paru && \
    makepkg -s --noconfirm
USER root
RUN pacman -U --noconfirm /tmp/paru/paru-bin-*-x86_64.pkg.tar.zst && \
    rm -rf /tmp/paru

# Install AUR-only-packages
RUN echo '"paru" ALL = (root) NOPASSWD:ALL' > /etc/sudoers.d/paru
USER paru
RUN AUR_PACKAGES=("icaclient" "quarto-cli-bin" "vim" "visual-studio-code-bin"); \
    for pkg in "${AUR_PACKAGES[@]}"; do \
    paru -Syu --needed --noconfirm "${pkg}"; \
    done
USER root
RUN rm /etc/sudoers.d/paru

# Remove paru user
RUN userdel -r paru

# Clean up caches to slim down image
RUN pacman -Scc --noconfirm
RUN paru -Scc --noconfirm

# Copy over scripts
COPY scripts /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Copy over /etc files
COPY etc /etc

# Generate extra locales (notably en_GB.UTF-8)
RUN locale-gen

# Symlink some external binaries, for convenience
RUN BINARIES=("flatpak" "podman" "rpm-ostree" "xdg-open" "notify-send"); \
    for binary in "${BINARIES[@]}"; do \
    ln -fs /usr/bin/distrobox-host-exec "/usr/local/bin/$binary"; \
    done
