#!bash
#Xvfb :2 &
#export DISPLAY=:2

path=/home/guanpeikun/tools/cytoscape/
cd $path
java `cat ./Cytoscape.vmoptions` -jar ./cytoscape.jar -p ./plugins &
cd -
