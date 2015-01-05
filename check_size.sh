for i in `l | awk '$3 ~ /guanpeikun/' | awk '{print $9}'`; do du -h --max-depth=0 $i; done
