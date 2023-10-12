FROM archlinux
LABEL org.opencontainers.image.authors="scroogemcfawk"

ENV PORT=8080

RUN pacman -Sy --noconfirm
RUN pacman -S --noconfirm jdk-openjdk
RUN pacman -S --noconfirm kotlin

WORKDIR /home/build-system/

COPY . .