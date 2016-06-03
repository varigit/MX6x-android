#/system/bin/sh

max=10
count=0

while ! svc power stayon true; do
    sleep 5
    count=$(($count + 1))
    if [ $count -ge $max ]; then
        break
    fi
done