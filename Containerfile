FROM quay.io/toolbx-images/archlinux-toolbox:latest

LABEL com.github.containers.toolbox="true" \
      name="toolbox" \
      version="base-devel" \
      usage="This image is meant to be used with the toolbox/distrobox command" \
      summary="PopeRigby's personal toolbox" \
      maintainer="PopeRigby <poperigby@mailbox.org>"

# Install extra packages
COPY extra-packages.txt /
RUN pacman -Syu --needed --noconfirm - < extra-packages.txt
RUN rm /extra-packages.txt

# Create a non-root user for makepkg and switch to it
RUN useradd -m paru
USER paru

# Build paru
RUN git clone https://aur.archlinux.org/paru-bin.git /tmp/paru && \
    cd /tmp/paru && \
    makepkg -s --noconfirm

# Switch back to root
USER root

# Clean up non-root user
RUN userdel -r paru

# Install paru
RUN pacman -U --noconfirm /tmp/paru/paru-bin-*-x86_64.pkg.tar.zst && \
    rm -rf /tmp/paru

# Clean up cache
RUN pacman -Scc --noconfirm

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
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open && \
    ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/notify-send
