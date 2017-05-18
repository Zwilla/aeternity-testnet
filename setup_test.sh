#!/usr/bin/env bash
# READ THIS: https://github.com/Zwilla/aeternity-testnet/blob/master/docs/testnet.md

      checkvalid=${PWD##*/};
      if [ $checkvalid == 'aeternity-testnet' ]; then
      echo "ok";
      else
      echo "aeternity-testnet folder not found";
      echo "use this to get a valid copy now.";
      echo "git clone https://github.com/Zwilla/aeternity-testnet.git";
      echo "#########################################################";
      exit 0;
      fi;

echo "Do you want to ... an Aeternity Testnet"
choices=( 'update and setup!' 'start the now!' 'how to?' 'clean and stop' 'run test' 'exit!' );
select choice in "${choices[@]}"; do

 [[ -n ${choice} ]] || { echo "Invalid choice! Type 1/2/3 or 4, please." >&2; continue; }

  case ${choice} in
    'update and setup a Testnet!')
             echo "Setup a Testnet..."
             echo "######################### CLEAN APP #########################";
             ./rebar clean;
             echo "######################### GET DEPS for ######################";
             ./rebar get-deps;
             ./rebar -r update-deps;
             echo "######################### COMPILE APP #######################";
             ./rebar compile;
             cd ..
             echo "######################### RM 3010 #######################";
             sudo rm -R aeternity-testnet3010
             echo "######################### RM 3020 #######################";
             sudo rm -R aeternity-testnet3020
             echo "######################### RM 3030 #######################";
             sudo rm -R aeternity-testnet3030
             echo "######################### CP 3010 #######################";
             cp -R aeternity-testnet aeternity-testnet3010
             chmod -R 777 aeternity-testnet3010
             echo "######################### CP 3020 #######################";
             cp -R aeternity-testnet aeternity-testnet3020
             chmod -R 777 aeternity-testnet3020
             echo "######################### CP 3030 #######################";
             cp -R aeternity-testnet aeternity-testnet3030
             chmod -R 777 aeternity-testnet3030

             echo "######################### RM EBIN 3010/3020/3030 #######################";
             rm -R aeternity-testnet3010/ebin
             rm -R aeternity-testnet3020/ebin
             rm -R aeternity-testnet3030/ebin
             echo "######################### RM KEYS 3010/3020/3030 #######################";
             rm aeternity-testnet3010/data/keys*
             rm aeternity-testnet3020/data/keys*
             rm aeternity-testnet3030/data/keys*

             echo "######################### COMPILE 3010 #######################";
             cd aeternity-testnet3010
             ./rebar compile
             touch 3010.txt
             sh initd-aeternity.sh start;
             cd ..

             echo "######################### COMPILE 3020 #######################";
             cd aeternity-testnet3020
             ./rebar compile
             touch 3020.txt
             sh initd-aeternity.sh start;
             cd ..

             echo "######################### COMPILE 3030 #######################";
             cd aeternity-testnet3030;
             ./rebar compile;
             touch 3030.txt;
             sh initd-aeternity.sh start;
             cd ..;


             echo "######################### START 3010 #######################";
             cd aeternity-testnet3010;
             #sh initd-aeternity.sh start;
             cd ..;

             echo "######################### START 3020 #######################";
             cd aeternity-testnet3020;
             #sh initd-aeternity.sh start;
             cd ..;

             echo "######################### START 3030 #######################";
             cd aeternity-testnet3030;
             #sh initd-aeternity.sh start;
             cd ..;

             echo "check now with screen command example: \n";
             echo "s c r e e n  - r aeternity-3010 \n or this";
             echo "s c r e e n  - r aeternity-3020 \n or this";
             echo "s c r e e n  - r aeternity-3030 \n ok?";
             ;;

      'start the Testnet now!')


      if [ -d '../aeternity-testnet3010' ] && [ -d '../aeternity-testnet3020' ] && [ -d '../aeternity-testnet3030' ]; then
      echo "ok";
      else
      continue;
      fi;

             cp initd-aeternity.sh ../aeternity-testnet3010/
             cp initd-aeternity.sh ../aeternity-testnet3020/
             cp initd-aeternity.sh ../aeternity-testnet3030/

             for i in `ps -ef | grep erl | awk '{print $2}'`; do echo ${i}; kill -9 ${i}; done

             cd ..
             cd aeternity-testnet3010
             rm data/*.db;
             rm -R blocks;
             mkdir -p blocks;
             touch 3010.txt;
             sh initd-aeternity.sh start;

             cd ..;
             cd aeternity-testnet3020;
             rm data/*.db;
             rm -R blocks;
             mkdir -p blocks;
             touch 3020.txt;
             sh initd-aeternity.sh start;

             cd ..;
             cd aeternity-testnet3030
             rm data/*.db;
             rm -R blocks;
             mkdir -p blocks;
             touch 3030.txt;
             sh initd-aeternity.sh start;
             ;;

      'how to?')
                 clear;
                 cat docs/testnet.md;
                 echo "\n";
                 echo "1. setup and update";
                 echo "2. start a Testnet";
                 echo "3. show HowTo again";
                 echo "4. clean all and stop testnet";
                 echo "5. run tests";
                 echo "6. exit now";
                 continue;
                 ;;
    'clean and stop')
                 echo "stop all Nodes now! ############";
                 sh initd-aeternity.sh stop;
                 cd ..
                 echo "######################### RM 3010 #######################";
                 sudo rm -R aeternity-testnet3010
                 echo "######################### RM 3020 #######################";
                 sudo rm -R aeternity-testnet3020
                 echo "######################### RM 3030 #######################";
                 sudo rm -R aeternity-testnet3030
                 ;;

    'run test')
                 sh tests/lightning_test.sh;
                 echo "\n";
                 echo "1. setup and update";
                 echo "2. start a Testnet";
                 echo "3. show HowTo again";
                 echo "4. clean all and stop testnet";
                 echo "5. run tests again";
                 echo "6. exit now";
                 continue;
    ;;
    'exit now!')
                 echo "Exiting the Aeternity Testnet setup. \n";
                 echo "#######################################";
                 exit 0;
                 esac

echo "ok";
  break

done

exit;



#rm blocks/*.db;
#-bash: /bin/rm: Argument list too long


exit;

