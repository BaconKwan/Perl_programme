args<-commandArgs(T)

library(RCytoscape)
g <- new('graphNEL', edgemode='undirected')

## read node file
node = read.table(args[1], sep="\t", comment.char = "`")
for (i in 1:nrow(node)){
	g <- graph::addNode(as.character(node[i,1]), g)
}

## read edge file
edge = read.table(args[2], sep="\t")
for (i in 1:nrow(edge)){
	g <- graph::addEdge(as.character(edge[i,1]), as.character(edge[i,2]), g)
}

## establish connection to Cytoscape
cy <- CytoscapeConnection()
deleteAllWindows(cy)
## init
setDefaultBackgroundColor (cy, '#ffffff')
cw <- new.CytoscapeWindow (args[3], graph=g)
setDefaultNodeShape (cw, 'round_rect')
setWindowSize (cw, 1612, 1231)
displayGraph (cw)
## modif node
for (i in 1:nrow(node)){
	setNodeColorDirect (cw, as.character(node[i,1]), as.character(node[i,2]))
}
## adjust network layout
layoutNetwork (cw, 'force-directed')
redraw (cw)
## adjust img size
zoom <- getZoom(cw) * 0.9
setZoom(cw, zoom)
## save img
id = paste(args[3], ".png", sep="")
saveImage (cw, id, 'png', 1.0)
