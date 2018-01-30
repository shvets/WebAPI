
1. Install homebrew

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

2. Create Brewfile in home:

```ruby
cask_args appdir: '/Applications'

tap 'homebrew/bundle'
tap 'caskroom/cask'
tap 'homebrew/services'
tap 'homebrew/dupes'

#brew 'vim'
#brew 'tmux'
#brew 'ruby-build'
#brew 'rbenv'

brew 'gpg'
brew 'git'
brew 'yarn'
brew 'wget'
brew 'mc'
brew 'fish'
brew 'ssh-copy-id'

cask 'sublime-text'
cask 'google-chrome'
cask 'vlc'
cask 'dropbox'
cask 'skype'
cask 'tunnelblick'
cask 'hipchat'
cask 'firefox'
cask 'biba'
```

3. Run brew bundle to install dependencies:

```bash
brew bundle

brew install --force openssl
```

4. Configure dropbox, skype, hipchat etc.

5. Install nvm and node:

```bash
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash

nvm install 5.11.0

nvm use 5.11.0
```

6. Install rvm and ruby:

```bash
curl -sSL https://get.rvm.io | bash

rvm autolibs enable
rvm install ruby-2.4.0
```

7. Install iterm2

8. Export/import Chrome bookmarks

9. Configure git repositories. Set-up 2F autorization

```bash
cd ~/.ssh

ssh-keygen

cat ~/.ssh/id_rsa_github.pub

```
- add public key to github configuration.

- create ~/.ssh/config file that points to new private key   
     
```bash

cat >> ~/.ssh/config <<EOF
Host github.com
  Hostname ssh.github.com
  Port 443
  IdentityFile ~/.ssh/id_rsa_github
EOF
```

- add private key to the ssh-agent (to use git from command line):

```bash
eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_rsa_github
```

10. Configure fish:

```bash
echo "/usr/local/bin/fish" | sudo tee -a /etc/shells

chsh -s /usr/local/bin/fish

mkdir -p ~/.config/fish

fish_config
```

```~/.config/fish
set -g -x PATH /usr/local/bin $PATH

source ~/Dropbox/.config/fish/config.fish

```

11. Add Chrome extensions:

- Augury
- Tidy Sidebar
- HTML5 Storage Manager All In One
- GitHub File Icon
