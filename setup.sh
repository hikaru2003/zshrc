o "🚀 Starting environment setup for Hikaru..."

# 1. OSの判定
OS="$(uname)"

# 2. パッケージマネージャーによるインストール
if [ "$OS" == "Darwin" ]; then
    echo "🍺 Detected macOS. Using Homebrew..."
    # Homebrewが入っていない場合はスキップ（手動インストールを推奨）
    if ! command -v brew &> /dev/null; then
        echo "⚠️ Homebrew is not installed. Please install it first: https://brew.sh/"
    else
        brew install fzf zoxide nvm bat
    fi
elif [ "$OS" == "Linux" ]; then
    echo "🐧 Detected Linux. Using apt..."
    sudo apt update && sudo apt install -y fzf zoxide bat git
    # Linuxでのnvmはcurl経由が一般的
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# 3. ディレクトリの作成
mkdir -p "$HOME/.zsh"

# 4. git-prompt.sh のダウンロード (未導入の場合)
# システム標準パスにない場合に備え、~/.zsh/ に直接配置します 
GIT_PROMPT_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
if [ ! -f "$HOME/.zsh/git-prompt.sh" ]; then
    echo "📥 Downloading git-prompt.sh..."
    curl -o "$HOME/.zsh/git-prompt.sh" $GIT_PROMPT_URL
else
    echo "✅ git-prompt.sh already exists."
fi

# 5. zsh-autosuggestions のダウンロード
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    echo "📥 Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
fi

# 6. fzf の有効化
if command -v fzf &> /dev/null; then
    $(brew --prefix 2>/dev/null || echo "/usr/share/doc/fzf/examples")/opt/fzf/install --all
fi

echo "✨ Setup complete! Please restart your terminal or run 'source ~/.zshrc'"
