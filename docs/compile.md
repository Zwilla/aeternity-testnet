Make sure that your system is up-to-date and that you are running Ubuntu 16 or later:

(earlier versions of ubuntu requires manually installing the latest version of erlang, because the package manager installs an old version)

Use this command to check your version number
```
lsb_release -a
```

```
sudo apt-get update
```
and
```
sudo apt-get upgrade
```

For Ubuntu, install following dependencies:

```
sudo apt-get install erlang libncurses5-dev libssl-dev unixodbc-dev g++ git erlang-base-hipe
```

Next, download Aeternity Testnet. Optionally you can run next steps with a non-root user, for better security.

```
git clone https://github.com/aeternity/testnet.git
```
Now you can go into the directory, and compile the aeternity testnet.

```
cd testnet/
sh install.sh
```

Installation should be done. Now you can run your node.

_Note: Deprecated Erlang build tool that makes it easy to compile and test Erlang applications, 
port drivers and releases. We encourage you to move to https://github.com/erlang/rebar3._
