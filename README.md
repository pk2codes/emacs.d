# Emacs Configuration

Personal Emacs setup for development — featuring LSP, Helm, Treemacs, SLIME,
CIDER, web/TypeScript tooling, and native compilation disabled for stability.

## Requirements

### System Dependencies

```bash
# Emacs 29.3+
sudo apt install emacs

# Ripgrep (für helm-rg / C-a Suche)
sudo apt install ripgrep

# JetBrains Mono Font
sudo apt install fonts-jetbrains-mono
# oder manuell: https://www.jetbrains.com/lego/monofont/

# SBCL (für Common Lisp / SLIME)
sudo apt install sbcl

# Node.js + npm (für TypeScript / LSP / ESLint)
sudo apt install nodejs npm

# Clojure + Leiningen (für CIDER)
sudo apt install clojure
# Leiningen:
curl -o ~/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
chmod +x ~/bin/lein

# Git (für Magit)
sudo apt install git
