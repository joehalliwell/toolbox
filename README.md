# Toolbox

Personal toolbox to be used with DistroBox or Toolbox.

## Use

### [DistroBox](https://distrobox.it/)

```bash
distrobox create -i ghcr.io/joehalliwell/toolbox toolbox
```

### [Toolbx](https://containertoolbx.org/)

```bash
toolbox create -i ghcr.io/joehalliwell/toolbox toolbox
```

### Build

(from the project root)

```bash
podman build --tag toolbox .
toolbox create -i localhost/toolbox:latest local-toolbox
```

## TODO

- Chezmoi/dotfiles setup
- Pyenv setup
