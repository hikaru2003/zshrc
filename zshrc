# ==============================================================================
# 0. PATHの設定 (ここが重要！)
# ==============================================================================
# OS標準のパスを確実に含め、既存のPATHを引き継ぐ
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Homebrewを使っている場合 (macOS)
if [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# 自分のローカルツールパスを追加
[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

# 色設定用の変数を有効化する
autoload -U colors; colors

# ==============================================================================
# 1. 基本設定 / 履歴強化
# ==============================================================================
export LANG=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=exfxcxdxcxegedabagacad
export LS_COLORS='di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt hist_ignore_all_dups # 重複を記録しない
setopt share_history        # 履歴を即座に共有
setopt EXTENDED_HISTORY     # 実行時刻も記録
unsetopt BEEP               # うるさい音を消す

# ==============================================================================
# 2. エイリアス (安全 & 便利)
# ==============================================================================
alias c=clear
alias change="source ~/.zshrc"
alias ll="ls -lah"
alias lst="ls -lt | head -n 20"
alias grep='grep --color=auto'

# Git 関連
alias ga="git add"
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gs="git status"
alias gg="git log"
alias gch="git checkout"
alias gb="git branch"

# ==============================================================================
# 3. 外部ツール連携 (fzf / zoxide / mise)
# ==============================================================================

# zoxide (cd の強化版: z で移動) があれば有効化
if type zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi

if type fzf > /dev/null 2>&1; then
    # Ctrl + R で履歴をあいまい検索
    function select-history() {
        BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
        CURSOR=$#BUFFER
    }
    zle -N select-history
    bindkey '^r' select-history

    # ディレクトリ移動 (fd)
    cd-fzf-find() {
      local dir
      dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) && cd "$dir"
    }
    alias fd=cd-fzf-find
fi

# ==============================================================================
# 4. 便利関数
# ==============================================================================

# backup <file> で日付付きバックアップ作成
function backup() {
  if [ -e "$1" ]; then
    cp -r "$1" "$1.`date '+%Y%m%d-%H%M%S'`.bak"
    echo "Backup created: $1.bak"
  fi
}

# ==============================================================================
# 5. プロンプト設定 (Git Status & Emoji)
# ==============================================================================
# git-prompt.sh の読み込み (存在チェック付き)
# macOS標準パスや .zsh 直下など、複数の可能性をチェック
GIT_PROMPT_PATHS=(
    "$HOME/.zsh/git-prompt.sh"
    "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
    "/usr/share/git-core/git-prompt.sh"
)

# 注意: zsh では path は PATH と連動する特別な配列。for path は PATH を壊すので別名を使う
for _git_prompt_path in $GIT_PROMPT_PATHS; do
    if [ -f "$_git_prompt_path" ]; then
        source "$_git_prompt_path"
        break
    fi
done

# Gitプロンプトの挙動設定
GIT_PS1_SHOWDIRTYSTATE=true 
GIT_PS1_SHOWUNTRACKEDFILES=true 
GIT_PS1_SHOWSTASHSTATE=true 
GIT_PS1_SHOWUPSTREAM=auto 

# 絵文字ランダム表示設定
FACE_LIST=("🐬" "🐰" "🐣" "🐧" "🐒" "🐴" "🐶" "🦊" "🐺" "🐯" "🐨" "🦭" "🐻" "🐢" "🦉" "🦁" "🦔" "🦈" "🐳" "🐊" "🐼" "🐐" "🦙" "🐪") 
function randomize_face() {
    FACE1=${FACE_LIST[$((1 + $RANDOM % ${#FACE_LIST[@]}))]}
    FACE2=${FACE_LIST[$((1 + $RANDOM % ${#FACE_LIST[@]}))]}
}

function git_color() {
  local git_info="$(__git_ps1 "%s")"
  if [[ $git_info == *"%"* ]] || [[ $git_info == *"*"* ]]; then 
    echo '%F{red}'
  elif [[ $git_info == *"+"* ]]; then 
    echo '%F{yellow}'
  else
    echo '%F{#00ff82}'
  fi
}

function get_status() {
    if type __git_ps1 > /dev/null 2>&1; then
        local git_status="$(__git_ps1 "%s")"
        if [[ -n $git_status ]]; then
            echo "%f[$(git_color)$git_status%f] "
        fi
    fi
}

# プロンプト反映
setopt PROMPT_SUBST 
precmd() { randomize_face } 
PS1='$FACE1 %F{magenta}%~%f $(get_status)$FACE2
$> ' 

# ==============================================================================
# 6. 外部ツール連携 (NVM / SDKs)
# ==============================================================================
# NVM (存在する場合のみ読み込み)
export NVM_DIR="$HOME/.nvm" 
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ==============================================================================
# 7. 入力サジェスト (zsh-autosuggestions)
# ==============================================================================
# プラグインが存在する場合のみ読み込む
if [ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ==============================================================================
# 8. 入力履歴検索 (zsh-history-substring-search)
# ==============================================================================
# プラグインが存在する場合のみ読み込む
if [ -f "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh" ]; then
    source "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi

# キーバインドの設定
# 上矢印: 履歴検索（入力があれば絞り込み、なければ通常の戻る）
bindkey '^[[A' history-substring-search-up
# 下矢印: 履歴検索（入力があれば絞り込み、なければ通常の進む）
bindkey '^[[B' history-substring-search-down
