#!/bin/sh
#
# Run cytoscape from a jar file
# This script is a UNIX-only (i.e. Linux, Mac OS, etc.) version
#-------------------------------------------------------------------------------

script_path="/home/guanpeikun/tools/cytoscape"
#echo $script_path
if [ -h $script_path ]; then
	script_path="$(readlink $script_path)"
fi

vm_options_path=$HOME/.cytoscape
#vm_options_path=$script_path

# Link CytoscapeRPC.conf to current path if it doesn't exist!
if [ ! -e "./CytoscapeRPC.conf" ]; then
	echo "*** Missing CytoscapeRPC.conf, now relink file to current path!"
	ln -s "$script_path/CytoscapeRPC.conf" "./CytoscapeRPC.conf"
#echo "*** please modif port option to what you want in CytoscapeRPC.conf"
#echo "*** please rerun $0"
#exit 0
fi

# Attempt to generate Cytoscape.vmoptions if it doesn't exist!
if [ ! -e "$vm_options_path/Cytoscape.vmoptions"  -a  -x "$script_path/gen_vmoptions.sh" ]; then
    "$script_path/gen_vmoptions.sh"
fi

if [ -r $vm_options_path/Cytoscape.vmoptions ]; then
    java `cat "$vm_options_path/Cytoscape.vmoptions"` -jar "$script_path/cytoscape.jar" -p "$script_path/plugins" "$@"
else # Just use sensible defaults.
    echo '*** Missing Cytoscape.vmoptions, falling back to using defaults!'
    java -Dswing.aatext=true -Dawt.useSystemAAFontSettings=lcd -Xss512M -Xmx4G \
	-jar "$script_path/cytoscape.jar" -p "$script_path/plugins" "$@"
fi
