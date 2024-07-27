#!/bin/bash

find -type f -name '*.png' ! -path '*afflicted*' -execdir bash -c 'for arg do mkdir -p afflicted; convert $arg -colorspace Gray "./afflicted/${arg:2:-4}_gray.png" ; done' _ {} +

#find -type f -name '*.png' -execdir bash -c 'for arg do echo "./afflicted/${arg:2:-4}_gray.png" ; done' _ {} +
