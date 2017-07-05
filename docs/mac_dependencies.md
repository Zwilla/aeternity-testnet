install erlang version 18 or higher.
You may need to install from source http://www.erlang.org/downloads



Or use [Homebrew](https://brew.sh) to compile and run the testnet:

1. login to your mac, open a terminal window (on spotlight search just type in this `terminal.app` and hit enter)
2. Update your OSX system
3. copy and past the folowing commands into your terminal:
```````````````
xcode-select --install
# follow the steps on apple's popup window
xcode-select -p
# http://railsapps.github.io/installrubyonrails-mac.html
gcc --version
ruby -v
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install gpg
brew install erlang
brew link --overwrite erlang
brew install gnu-sed --with-default-names
brew link --overwrite gnu-sed
cd /Users/$LOGNAME/Downloads
mkdir -p aeternity/testnet/data/
mkdir -p aeternity/testnet/blocks/
cd /Users/$LOGNAME/Downloads/aeternity
git clone https://github.com/aeternity/testnet.git
cd testnet
mkdir data blocks
make release-build
```````````````

I hope it works for you also. Let us know it you have any problems

cheers
zwilla
