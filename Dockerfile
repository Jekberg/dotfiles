FROM archlinux:latest
RUN pacman --noconfirm -Syu
RUN pacman --noconfirm --needed -S arch-install-scripts git base-devel nix

ARG USERNAME=docker
ARG USER_UID=1000
ARG USER_GID=1000
RUN useradd --create-home $USERNAME
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
RUN chmod 0440 /etc/sudoers.d/$USERNAME

RUN git clone https://aur.archlinux.org/yay.git /usr/local/src/yay/
RUN chown -R $USERNAME:$USERNAME /usr/local/src/yay
USER $USERNAME
WORKDIR /usr/local/src/yay
RUN makepkg --noconfirm -si

USER $USERNAME
WORKDIR /home/$USERNAME

COPY . ./dotfiles/
CMD /bin/bash
# command:
# docker run --privileged --rm --volume /tmp/root:/mnt archlinux pacstrap /mnt
