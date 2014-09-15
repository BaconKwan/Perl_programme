library(pheatmap)
args<-commandArgs(T)
data = read.table(args[1], header = TRUE, sep = "\t", check.name = FALSE)
rownames(data) = data[,1]
data = data[,2:length(data[1,])]
id <- paste(args[1], ".pdf", sep="")
pdf(file = id, height = 10)
pheatmap(data, cluster_rows = FALSE, cluster_cols = FALSE, cellwidth = 70, cellheight = 10)
dev.off()
