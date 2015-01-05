## list size of each folder
for i in `l | awk '$3 ~ /guanpeikun/' | awk '{print $9}'`; do du -h --max-depth=0 $i; done
## calculate total size
for i in `l | awk '$3 ~ /guanpeikun/' | awk '{print $9}'`; do du --max-depth=0 $i; done | awk '{a+=$1}END{print a/1024/1024}'
