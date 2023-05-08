#!/bin/bash

winpty docker run --rm -v /$(pwd)/data:/home/data --hostname bio634 --name bio634 -ti dktanwar/bio634 bash --login
