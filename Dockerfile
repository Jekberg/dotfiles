FROM gentoo/stage3:systemd
RUN emerge -q --sync
RUN MAKEOPTS="-j$(nproc)"   \
    emerge -uqvDN @world

# NOTE any change to the context causes a rebuild. It would be nice to
# avoid this.
COPY . /tmp/dotfiles
WORKDIR /tmp/dotfiles
RUN ./scripts/gentoo/install.sh

ARG USERNAME=docker
ARG USER_UID=1000
ARG USER_GID=1000
RUN useradd --create-home $USERNAME
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
RUN chmod 0440 /etc/sudoers.d/$USERNAME

# TODO configure the user
USER $USERNAME
WORKDIR /home/$USERNAME
