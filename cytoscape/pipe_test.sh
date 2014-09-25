## run this fisrt -> Xvfb :2 &
export DISPLAY=:2 && sh ./cytoscape.sh &
sleep 90
Rscript RCytoscape.r /Bio/Project/PROJECT/GDB004/color/magenta.node_arr /Bio/Project/PROJECT/GDB004/color/magenta.edge magenta
kill `psc | grep "cytoscape" | awk '{print $1}'`
