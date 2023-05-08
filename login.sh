#!/bin/bash

command=`docker container ls -a|grep dktanwar/bio634`
#echo $command
if [ -z "$command" ]; then
  docker run -v `pwd`/data:/home/data --hostname bio634 --name bio634 -ti dktanwar/bio634 bash --login
else
  docker container start bio634
  docker exec -it bio634 bash
fi
