#!/bin/bash
#clean larger than 1G files
for j in `du -ha -t 1G ./* | cut -f 2`; do rm $j; done
