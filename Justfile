build:
    podman build --tag toolbox .
    toolbox create -i localhost/toolbox:latest local-toolbox

lint:
    #!/bin/bash
    MANIFEST=packages/pacman.txt
    TEMP=$(mktemp)
    grep "^#" "$MANIFEST" >> "$TEMP"
    grep -v "^#" "$MANIFEST" >> "$TEMP"
    mv "$TEMP" "$MANIFEST"
