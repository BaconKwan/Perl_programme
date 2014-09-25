#!bash
path=/home/guanpeikun/tools/cytoscape/

java `cat "$path/Cytoscape.vmoptions"` -jar "$path/cytoscape.jar" -p "$path/plugins"
