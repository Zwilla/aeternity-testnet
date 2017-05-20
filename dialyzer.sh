#!/usr/bin/env bash
# Erlang Dialyzer Script to find errors
# copyright michael.padilla@zwilla.de 2017
#
# How to?
#
# just run it and check the dialyzer-result.txt
#
echo "######################### CLEAN APP #########################";
./rebar clean
echo "######################### GET DEPS for ######################";
./rebar get-deps
./rebar -r update-deps
#./rebar delete-deps
#./rebar qc
#./rebar xref
#./rebar shell

echo "######################### COMPILE APP #######################";
./rebar compile

if [ ! -e dialyzer-aeternity.plt ]; then

       echo "######################### build the dializer #########################";
       # more here: http://erlang.org/doc/apps/dialyzer/dialyzer_chapter.html
       dialyzer --build_plt --output_plt dialyzer-aeternity.plt --apps erts kernel stdlib mnesia compiler crypto hipe syntax_tools;
       echo "######################### ADD APP AETERNITY ##########################";
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt ebin/*.beam;

       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/chalang/ebin/*.beam;
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/cowboy/ebin/*.beam;
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/cowlib/ebin/*.beam;
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/dump/ebin/*.beam;
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/jiffy/ebin/*.beam;
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/pink_hash/ebin/*.beam;
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/ranch/ebin/*.beam;
       dialyzer --add_to_plt --output_plt dialyzer-aeternity.plt deps/trie/ebin/*.beam;


       echo "######################### CHECK the dializer #########################";
       dialyzer --check_plt --plt dialyzer-aeternity.plt;
       echo "######################### INFO ABOUT #################################";
       dialyzer --plt_info --plt dialyzer-aeternity.plt;
       echo "######################### BUILD RESULT OF ############################";
       dialyzer --plt dialyzer-aeternity.plt -o dialyzer-result.txt ebin/;
       echo "######################### THE RESULT OF ##############################";
       cat dialyzer-result.txt;
       echo "######################### FINISH BUILD ##############################";

else

       echo "######################### checking now #########################";
       dialyzer --check_plt --plt dialyzer-aeternity.plt;
       # remove old file
       rm dialyzer-result.txt;
       echo "######################### BUILD RESULT OF ############################";
       dialyzer --plt dialyzer-aeternity.plt -o dialyzer-result.txt ebin/;
       echo "######################### THE RESULT OF ##############################";
       cat dialyzer-result.txt;
       echo "######################### FINISH DIALYZER update ##############################";

fi;

echo "
  Donate to .. and support Zwilla: \n
  * btc:1DaGkc1Uv4GeCSpjkrMVzCA35ENmrd526V \n
  * eth:0x284DbB6139e2e08cd3D3BE6f51306c19cAB04e3c \n
  * ltc:LNvu63U68G72KXHWP5yqSuSYpoa7ef58c7 \n
  " >> dialyzer-result.txt;
