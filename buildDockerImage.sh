#!/usr/bin/bash

{
  docker --version &> /dev/null
} || {
  echo "Can not build image. Docker is not installed."
  exit 1
}

if [[ $(docker info) == *"docker daemon is not running"* ]]; then
  {
    sudo systemctl start docker
  } || {
    echo "Cat not start docker."
    exit 1
  }
fi

{
  docker build -f ./Dockerfile -t scroogemcfawk/jkbs:1.0 .
} || {
  echo "Can not build an image due to unexpected error."
  exit 1
}



