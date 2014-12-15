args<-commandArgs(T)
if(length(args) != 3){
	stop("Rscript RCytoscape.r <node> <edge> <outprefix>")
}

library(RCytoscape)
g <- new('graphNEL', edgemode='undirected')
port = 9000

## read node file
node = read.table(args[1], sep="\t", comment.char = "`")
cl <- colorRampPalette(c("green", "black", "red"))(1000)
for (i in 1:nrow(node)){
	g <- graph::addNode(as.character(node[i,1]), g)
	if(node[i, 2] < -5)
	{
		node[i, 3] <- cl[1]
	}else if(node[i, 2] > 5){
		node[i, 3] <- cl[1000]
	}else if(node[i, 2] >= -5 && node[i, 2] <= 0){
		node[i, 3] <- cl[500 - as.integer(node[i, 2] * (-100))]
	}else{
		node[i, 3] <- cl[500 + as.integer(node[i, 2] * 100)]
	}
}

## read edge file
edge = read.table(args[2], sep="\t")
for (i in 1:nrow(edge)){
	g <- graph::addEdge(as.character(edge[i,1]), as.character(edge[i,2]), g)
}

## establish connection to Cytoscape
cy <- CytoscapeConnection(rpcPort = port)
deleteAllWindows(cy)
## init
setDefaultBackgroundColor(cy, '#ffffff')
cw <- new.CytoscapeWindow(args[3], graph=g, rpcPort = port)

##node 
setDefaultNodeShape(cw, 'ellipse')
setDefaultNodeLabelColor(cw, '#000000')

##edge
setDefaultEdgeColor(cw, '#c0c0c0')

setWindowSize(cw, 8012, 8031)
displayGraph(cw)
## modif node color
for(i in 1:nrow(node))
{
	if(node[i, 2] < -1 || node[i, 2] > 1)
	{
		setNodeColorDirect(cw, as.character(node[i, 1]), as.character(node[i, 3]))
	}else{
		setNodeColorDirect(cw, as.character(node[i, 1]), "#ffffff")
	}
}
#control.points <- c(-3.0, 0.0, 3.0)
#node.colors <- c("#00AA00", "#00FF00", "#FFFFFF", "#FF0000", "#AA0000")
#setNodeColorRule(cw, node.attribute.name='label', control.points, node.colors, mode='interpolate')

## adjust network layout
layoutNetwork(cw, 'force-directed')
redraw(cw)
## adjust img size
zoom <- getZoom(cw) * 0.9
setZoom(cw, zoom)
## save img
id = paste(args[3], '.png', sep='')
saveImage(cw, id, 'png', 1.0)
id = paste(args[3], '.gml', sep='')
saveNetwork(cw, id, format='gml')
