.DEFAULT_GOAL:=help
MAKEFLAGS+=--warn-undefined-variables
SHELL:=BASH_ENV= /bin/bash -e -o pipefail -u -c
.DELETE_ON_ERROR:
.SILENT:


DOTFILES := \
        emacs \
        xfce4-terminal \
        lxterminal \
        zsh \
        git \
        tmux \
        ssh \
        readline \
        colordiff \
        htop \
        less \
        unison \
        editorconfig \
        python


.PHONY: help all clean $(DOTFILES)

help:
	echo
	echo "SYNPOSIS"
	echo "    make TARGET [TARGET...]"
	echo "    make all"
	echo "    make clean"
	echo
	echo "DESCRIPTION"
	echo "    Installs dotfiles in the home directory. Installed dotfiles are"
	echo "    symlinks to files in this repo, or read-only files generated by"
	echo "    concatenation and/or patching of files from this repo or an"
	echo "    online source."
	echo
	echo "    'make all' installs all dotfiles. 'make clean' uninstalls them."
	echo
	echo "TARGETS:"
	$(foreach dotfile,$(DOTFILES),echo "    $(dotfile)";)

emacs: $(HOME)/.emacs.d/init.el
$(HOME)/.emacs.d/init.el: \
        $(addprefix emacs/, \
            usepackage_quelpa.el evil.el whitespace.el pairs.el margins.el \
            menu_and_mode_bars.el theme.el fonts.el splash_message.el \
            backup.el custom.el misc_keys.el mouse.el ido.el editorconfig.el \
            flycheck.el org.el markdown.el python.el proof_general.el)

xfce4-terminal: $(HOME)/.config/xfce4/terminal/terminalrc
$(HOME)/.config/xfce4/terminal/terminalrc: linux/xfce4_terminalrc

lxterminal: $(HOME)/.config/lxterminal/lxterminal.conf
$(HOME)/.config/lxterminal/lxterminal.conf: linux/lxterminal.conf

zsh: $(addprefix $(HOME)/,.zprofile .zshrc .zplug .autoenv.zsh)
$(HOME)/.zprofile: $(addprefix shell/shared/,path env term)
$(HOME)/.zshrc: \
        $(addprefix shell/shared/,misc less ls source-highlight ssh alias \
            local) \
        shell/zsh/zshrc
$(HOME)/.autoenv.zsh: shell/zsh/autoenv.zsh

git: $(addprefix $(HOME)/.config/git/,config ignore attributes) diff-highlight
$(HOME)/.config/git/config: git/config
$(HOME)/.config/git/ignore: git/ignore
$(HOME)/.config/git/attributes: git/attributes

.PHONY: diff-highlight
diff-highlight: $(HOME)/bin/diff-highlight

tmux: $(HOME)/.tmux.conf
$(HOME)/.tmux.conf: tmux/tmux.conf tmux/colorscheme_solarized_light.conf

ssh: $(HOME)/bin/ssh-agent-connect
$(HOME)/bin/ssh-agent-connect: bin/ssh-agent-connect

readline: $(HOME)/.inputrc
$(HOME)/.inputrc: util/inputrc

colordiff: $(HOME)/.colordiffrc
$(HOME)/.colordiffrc: util/colordiffrc

htop: $(HOME)/.config/htop/htoprc
$(HOME)/.config/htop/htoprc: util/htoprc

less: $(HOME)/bin/lesspipe highlight
$(HOME)/bin/lesspipe: bin/lesspipe

.PHONY: highlight
highlight: \
        $(HOME)/.config/source-highlight/esc.style \
        $(HOME)/.local/share/source-highlight
$(HOME)/.config/source-highlight/esc.style: util/source-highlight.style
$(HOME)/.local/share/source-highlight: source-highlight

unison: $(HOME)/.unison/default.prf
$(HOME)/.unison/default.prf: util/unison_default.prf

editorconfig: $(HOME)/.editorconfig
$(HOME)/.editorconfig: util/editorconfig

python: $(addprefix $(HOME)/,.mypy.ini .flake8 .pylintrc .isort.cfg)
$(HOME)/.mypy.ini: python/mypy.ini
$(HOME)/.flake8: python/flake8
$(HOME)/.pylintrc: python/pylintrc
$(HOME)/.isort.cfg: python/isort.cfg

# Symlink dotfile.
$(addprefix $(HOME)/, \
        .config/xfce4/terminal/terminalrc \
        .config/lxterminal/lxterminal.conf \
        .autoenv.zsh \
        $(addprefix .config/git/,config ignore attributes) \
        bin/ssh-agent-connect \
        .inputrc \
        .colordiffrc \
        .config/htop/htoprc \
        bin/lesspipe \
        .config/source-highlight/esc.style .local/share/source-highlight \
        .unison/default.prf \
        .editorconfig \
        .mypy.ini .flake8 .pylintrc .isort.cfg):
	mkdir -p "$$(dirname $@)"
	ln -sf "$(PWD)/$<" "$@"

# Generate dotfile by concatenation.
$(addprefix $(HOME)/, \
        .emacs.d/init.el \
        .zprofile .zshrc \
        .tmux.conf):
	rm -f "$@"
	mkdir -p "$$(dirname $@)"
	cat $^ > "$@"
	chmod -w "$@"

# Install zplug by cloning upstream repo.
$(HOME)/.zplug:
	git clone https://github.com/zplug/zplug "$@"

# Install diff-highlight (for git diff) by patching files in the upstream repo.
$(HOME)/bin/diff-highlight:
	rm -f $(HOME)/.local/share/perl5/lib/perl5/DiffHighlight.pm
	mkdir -p $(HOME)/.local/share/perl5/lib/perl5
	curl -fsS \
	    https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/DiffHighlight.pm \
	    > $(HOME)/.local/share/perl5/lib/perl5/DiffHighlight.pm
	chmod -w $(HOME)/.local/share/perl5/lib/perl5/DiffHighlight.pm
	rm -f "$@"
	mkdir -p "$$(dirname $@)"
	echo -e \
	    "#!/usr/bin/perl\n\nuse lib '$(HOME)/.local/share/perl5/lib/perl5';\nuse DiffHighlight;\n" \
	    > "$@"
	curl -fsS \
	    https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/diff-highlight.perl \
	    >> "$@"
	chmod -w+x "$@"

all: $(DOTFILES)

clean:
	rm -f $(addprefix $(HOME)/, \
	    .emacs.d/init.el \
	    .zprofile .zshrc .autoenv.zsh \
	    $(addprefix .config/git/,config ignore attributes) bin/diff-highlight \
	    .tmux.conf \
	    .inputrc \
	    .colordiffrc \
	    .config/htop/htoprc \
	    bin/lesspipe \
	    .config/source-highlight/esc.style .local/share/source-highlight \
	    .unison/default.prf \
	    .editorconfig \
        .mypy.ini .flake8 .pylintrc .isort.cfg)
