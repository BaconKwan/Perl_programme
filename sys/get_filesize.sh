du -h ./ > filesize_info.txt
awk '$1~/G/' filesize_info.txt | sort -k1nr > simple.filesize_info.txt
