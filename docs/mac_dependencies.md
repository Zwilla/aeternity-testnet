# TOC
* [Mac OS X Prerequisites](#mac-os-x-prerequisites)
* [Example 1: Erlang already installed on OSX](#example-1-erlang-already-installed-on-osx)
* [Example 2 with Homebrew](#example-2-with-homebrew)
* [Running the Blockchain](#running-the-blockchain)
***
## Mac OS X Prerequisites
* Erlang version 18 or higher.
You may need to install from source http://www.erlang.org/downloads
* Command Git
* X-Code command line tools (gcc,..,..,..)

If you have Erlang already on your machine you can compile it by this way:
## Example 1: Erlang already installed on OSX

1. Update your OSX system
2. Update Erlang it not newer than version 18
3. login to your mac, open a terminal window (on spotlight search just type in this `terminal.app` and hit enter)
4. Change into the directory where you want to install our software
5. Now run this commands:
````````
git clone https://github.com/aeternity/testnet.git
cd testnet
make prod-build
````````

## Example 2 with Homebrew
On this example we use [Homebrew](https://brew.sh) to compile and run the testnet:

1. Update your OSX system
2. login to your mac, open a terminal window (on spotlight search just type in this `terminal.app` and hit enter)
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
# You can use any other directory and have permissions for !
cd /Users/$LOGNAME/Downloads
mkdir -p aeternity
cd /Users/$LOGNAME/Downloads/aeternity
git clone https://github.com/aeternity/testnet.git
cd testnet
make prod-build
```````````````
***
## Running the blockchain

If you just want to launch a node and connect to the network, look at the [quick start guide](https://github.com/aeternity/testnet/blob/master/docs/turn_it_on.md)
***
Hope it works for you also. 
* Let us know if you have any issues [click here](https://github.com/aeternity/testnet/issues/new)
* If you have an other, better easier way - commit it here.

From time to time we will explain more examples how to compile Aeternity on OSX.
If you have an working example, feel free to commit it.

many thanks in advance

[☜](https://github.com/aeternity/testnet/tree/master/docs)...[☝︎](#toc)...[☞](https://github.com/aeternity/testnet/blob/master/docs/turn_it_on.md)

