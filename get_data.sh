#!/bin/bash
PROG=$(basename $0)
NO_ARGS=0 
E_OPTERROR=85

# Script invoked with no command-line args?
if [ $# -eq "$NO_ARGS" ]; then
  echo "Usage: $prog [-h host] [-u username] [-p password]"
  echo "       $prog -H for help."
  exit $E_OPTERROR
fi

showhelp() {
  echo "Usage: $PROG [-h host] [-u username] [-p password]"
  echo " -h: host"
  echo " -u: username"
  echo " -p: password"
  echo " -H: this help message"
  exit 2
}

USER=
HOST=
PASS=
NOW=$(date +"%m-%d-%Y")
DIR="data_$NOW"
FILE="data.tgz"

while getopts "h:u:p:H" name; do
	case $name in
		h) HOST=$OPTARG;;
		u) USER=$OPTARG;;
		p) PASS=$OPTARG;;
		H) showhelp $0;;
	esac
done

if [ -d "$DIR" ]; then
	rm -R $DIR
	mkdir $DIR
else
	mkdir $DIR
fi

CMD1=$(expect << EOF
spawn ssh $USER@$HOST
expect "password: "
send "$PASS\n"
expect "$ "
send "cd /tmp\n"
expect "$ "
send "tar -czf $FILE \`find . -maxdepth 1 -name 'f2p_*' -print\`\n"
expect "$ "
send "logout"
EOF)

CMD2=$(expect << EOF
spawn scp $USER@$HOST:/tmp/$FILE $DIR
expect "password: "
send "$PASS\n"
expect "$ "
EOF)

CMD3=$(expect << EOF
spawn ssh $USER@$HOST
expect "password: "
send "$PASS\n"
expect "$ "
send "cd /tmp\n"
expect "$ "
send "rm $FILE\n"
expect "$ "
send "logout"
EOF)

echo "$CMD1"
echo "$CMD2"
echo "$CMD3"
cd $DIR
tar -xzf $FILE
rm $FILE
COUNT=$(ls -1 | wc -l | awk '{gsub(/^ +| +$/, "")}1')
cd ..
clear
echo "All done. Extracted $COUNT *.net files."