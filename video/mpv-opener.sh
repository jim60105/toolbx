#!/bin/bash

# Remove the 'mpv:' prefix from the URL
url=${1#mpv}

# Run mpv with the modified URL
toolbox run -c video mpv -- https"$url"
