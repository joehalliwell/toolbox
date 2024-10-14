FROM quay.io/toolbx/arch-toolbox:latest

LABEL name="toolbox"
LABEL maintainer="Joe Halliwell <joe.halliwell@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/joehalliwell/toolbox"
LABEL org.opencontainers.image.description="Personal toolbox"
LABEL com.github.containers.toolbox="true"

################################################################################
#  Base configuration
################################################################################

# Copy over /etc files
COPY etc/locale.gen /etc/

# Generate extra locales (notably en_GB.UTF-8)
RUN locale-gen

################################################################################
# Install packages
################################################################################

# Install keys
RUN pacman-key --init
RUN pacman -Sy --noconfirm --debug archlinux-keyring

# Copy over package lists
COPY packages /tmp/packages/

# Pacman
RUN pacman -Syu --needed --noconfirm $(grep -v "^#" /tmp/packages/pacman.txt)

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
RUN for pkg in $(grep -v "^#" /tmp/packages/paru.txt); do \
    paru -Syu --needed --noconfirm "${pkg}"; \
    done
USER root
RUN rm /etc/sudoers.d/paru

# Remove paru user
RUN userdel -r paru

# Clean up caches to slim down image
RUN pacman -Scc --noconfirm
RUN paru -Scc --noconfirm
RUN rm -rf /tmp/packages

################################################################################
# Link with host
################################################################################

# Copy over scripts
COPY scripts /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Symlink some external binaries, for convenience
RUN BINARIES=("flatpak" "notify-send" "podman" "rpm-ostree" "xdg-open"); \
    for binary in "${BINARIES[@]}"; do \
    ln -fs /usr/local/bin/host-exec "/usr/local/bin/$binary"; \
    done
