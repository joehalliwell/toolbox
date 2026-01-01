FROM quay.io/toolbx/arch-toolbox:latest

LABEL name="toolbox"
LABEL maintainer="Joe Halliwell <joe.halliwell@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/joehalliwell/toolbox"
LABEL org.opencontainers.image.description="Personal toolbox"
LABEL com.github.containers.toolbox="true"

ARG AUR_HELPER=yay

################################################################################
#  Base configuration
################################################################################

# Copy over /etc files
COPY etc/locale.gen /etc/

# Generate extra locales (notably en_GB.UTF-8)
RUN locale-gen

################################################################################
# Install official packages
################################################################################

# Install keys
RUN pacman-key --init
RUN pacman -Sy --noconfirm --debug archlinux-keyring

# Copy over package lists
COPY packages /tmp/packages/

# Pacman
RUN pacman -Syu --needed --noconfirm $(grep -v "^#" /tmp/packages/pacman.txt)

################################################################################
# Install AUR packages
################################################################################

# Install an AUR helper and use it to install some awkward bits
RUN useradd -m builder
RUN echo '"builder" ALL = (root) NOPASSWD:ALL' > /etc/sudoers.d/builder
USER builder

# Build and install yay
RUN git clone https://aur.archlinux.org/yay-bin.git /tmp/yay && \
    cd /tmp/yay && \
    makepkg -si --noconfirm && \
    rm -rf /tmp/yay

# Install AUR-only-packages
RUN for pkg in $(grep -v "^#" /tmp/packages/paru.txt); do \
    yay -Syu --needed --noconfirm "${pkg}"; \
    done

RUN yay -Scc --noconfirm
# RUN paru -Scc --noconfirm

# Remove builder user
USER root
RUN rm /etc/sudoers.d/builder
RUN userdel -r builder

# Clean up caches to slim down image
RUN pacman -Scc --noconfirm
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
