build:
    mise exec -- bash build.sh

install-local:
    #!/usr/bin/env bash
    set -euo pipefail
    repo="{{justfile_directory()}}"
    os=$(uname -s)
    arch=$(uname -m)
    case "$os/$arch" in
      Darwin/arm64) artifact=gitego-darwin-arm64 ;;
      Darwin/x86_64) artifact=gitego-darwin-amd64 ;;
      Linux/x86_64) artifact=gitego-linux-amd64 ;;
      Linux/aarch64|Linux/arm64) artifact=gitego-linux-arm64 ;;
      *)
        echo "install-local: unsupported $os $arch (Windows: copy dist/*.exe manually; see comment in justfile)" >&2
        exit 1
        ;;
    esac
    src="$repo/dist/$artifact"
    if [[ ! -f "$src" ]]; then
      echo "install-local: missing $src — run 'just build' first" >&2
      exit 1
    fi
    mkdir -p "$HOME/.local/bin"
    ln -sf "$src" "$HOME/.local/bin/gitego"
    echo "Linked $src -> $HOME/.local/bin/gitego"
    case ":$PATH:" in
      *":$HOME/.local/bin:"*) ;;
      *)
        echo ""
        echo "~/.local/bin is not on PATH yet — \`gitego\` will be \"command not found\" until you fix that."
        echo "  This terminal only:  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "  Permanent (zsh):     echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
        ;;
    esac
