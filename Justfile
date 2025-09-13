build:
    podman build --tag toolbox .
    toolbox create -i localhost/toolbox:latest local-toolbox
