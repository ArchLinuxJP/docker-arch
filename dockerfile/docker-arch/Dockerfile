FROM archlinuxjp/archlinux

RUN pacman -Syy arch-install-scripts expect docker --noconfirm
RUN mkdir -p /run/shm
RUN mkdir -p /mkimage-arch
ADD bin /
COPY mkimage-arch /mkimage-arch/
CMD /bin/bash
