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
