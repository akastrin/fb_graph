#!/bin/bash
prog=$(basename $0)
NO_ARGS=0 
E_OPTERROR=85

# Script invoked with no command-line args?
if [ $# -eq "$NO_ARGS" ]; then
  echo "Usage: $prog [-h host] [-u username] [-p password]"
  echo "       $prog -help for help."
  exit $E_OPTERROR
fi

showhelp() {
  echo "Usage: $prog [-h host] [-u username] [-p password]"
  echo " -h: host"
  echo " -u: username"
  echo " -p: password"
  echo " -help: this help message"
  exit 2
}

user=""
host=""
pass=""
now=$(date +"%m-%d-%Y")
dir="data_$now"
file="data.tgz"

while getopts "h:u:p:help" name; do
  case $name in
    h)
      host=$OPTARG
    ;;
    u)
      user=$OPTARG
    ;;
    p)
      pass=$OPTARG
    ;;
    help)
      showhelp $0
    ;;
  esac
done

if [ -d "$dir" ]; then
  rm -R $dir
  mkdir $dir
else
  mkdir $dir
fi

cmd1=$(expect << EOF
spawn ssh $user@$host
expect "password: "
send "$pass\n"
expect {
  "Permission denied, please try again." {
    send_user "Wrong password."
    exit
  }
  "$ " {
    send "cd /tmp\n"
    expect "$ "
    send "tar -czf $file \`find . -maxdepth 1 -name 'f2p_*' -print\`\n"
    expect "$ "
    send "logout"
    exit
  }
}
EOF)

cmd2=$(expect << EOF
spawn scp $user@$host:/tmp/$file $dir
expect "password: "
send "$pass\n"
expect "$ "
EOF)

CMD3=$(expect << EOF
spawn ssh $user@$host
expect "password: "
send "$pass\n"
expect "$ "
send "cd /tmp\n"
expect "$ "
send "rm $file\n"
expect "$ "
send "logout"
EOF)

echo "$cmd1"
echo "$?"
echo "$cmd2"
echo "$?"
echo "$cmd3"
cd $dir
tar -xzf $file
rm $file
count=$(ls -1 | wc -l | awk '{gsub(/^ +| +$/, "")}1')
cd ..
clear
echo "All done. Extracted $count *.net files."