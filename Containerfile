FROM docker.io/library/archlinux:base-devel

ENV NAME=archlinux-toolbox VERSION=base-devel
LABEL com.github.containers.toolbox="true" \
    name="$NAME" \
    version="$VERSION"

# Install base packages
COPY base-packages.txt /
RUN pacman -Syyu --needed --noconfirm - < base-packages.txt
RUN rm /base-packages.txt

# Install extra packages
COPY extra-packages.txt /
RUN pacman -Syu --needed --noconfirm - < extra-packages.txt
RUN rm /extra-packages.txt

# Clean up cache
RUN pacman -Scc --noconfirm

# Enable sudo permission for wheel users
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/toolbox

# Copy over scripts
COPY scripts /usr/local/bin
RUN chmod +x /usr/local/bin/_chezmoi_setup \
    /usr/local/bin/ostree \
    /usr/local/bin/systemctl

# Copy over /etc files
COPY etc /etc

# Symlink some external binaries, for convenience
RUN ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/distrobox && \ 
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/notify-send
