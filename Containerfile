FROM quay.io/toolbx-images/archlinux-toolbox:latest

LABEL name="toolbox"
LABEL maintainer="Joe Halliwell <joe.halliwell@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/joehalliwell/toolbox"
LABEL org.opencontainers.image.description="Personal toolbox"
LABEL com.github.containers.toolbox="true"

# Install packages
COPY packages.txt /
RUN pacman -Syu --needed --noconfirm - < packages.txt
RUN rm /packages.txt

# Create a non-root user for makepkg and switch to it
RUN useradd -m paru
USER paru

# Build paru
RUN git clone https://aur.archlinux.org/paru-bin.git /tmp/paru && \
    cd /tmp/paru && \
    makepkg -s --noconfirm

# Switch back to root
USER root

# Install paru
RUN pacman -U --noconfirm /tmp/paru/paru-bin-*-x86_64.pkg.tar.zst && \
    rm -rf /tmp/paru

# Clean up non-root user
RUN userdel -r paru

# Install AUR-only-packages
USER paru
RUN AUR_PACKAGES=("quarto-cli-bin"); \
    for pkg in "${AUR_PACAKGES[@]}"; do \
    paru -Syu "${pkg}"; \
    done
USER root


# Clean up cache
RUN pacman -Scc --noconfirm

# Copy over scripts
COPY scripts /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# Copy over /etc files
COPY etc /etc

# Symlink some external binaries, for convenience
RUN BINARIES=("flatpak" "podman" "rpm-ostree" "xdg-open" "notify-send"); \
    for binary in "${BINARIES[@]}"; do \
    ln -fs /usr/bin/distrobox-host-exec "/usr/local/bin/$binary"; \
    done

RUN pyenv install --verbose 3.12
RUN pyenv global 3.12
