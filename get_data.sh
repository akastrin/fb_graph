#!/bin/bash
USER=$1
HOST=$2
PASS=$3
NOW=$(date +"%m-%d-%Y")
DIR="data_$NOW"
FILE="data.tgz"

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