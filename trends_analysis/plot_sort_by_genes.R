args<-commandArgs(T)
data=read.table(args[1], sep = "\t")
profile_counts=nrow(data)
rx=1
while(rx*0.88*rx<=profile_counts)
{
	rx=rx+1
}
#rx
#row_counts=as.numeric(args[2])
row_counts=rx
total_counts=0
if(profile_counts%%row_counts==0)
{
	total_counts=profile_counts
}
if(profile_counts%%row_counts!=0)
{
	total_counts=(as.integer(profile_counts/row_counts)+1)*row_counts
}
mat=t(matrix(1:total_counts,nrow=row_counts))
pdf(paste(args[1],"sort_by_genes.pdf",sep="."),10,8)
layout(mat)
colors=c("lightgreen","lightblue","lightpink")
palette(colors)
ddd=1
for(i in order(data[,4],decreasing=T))
{
	y=as.numeric(strsplit(as.character(data[i,2]),",")[[1]])
	x=1:length(y)
	max_y=max(abs(y))*1.15
	par(mar=c(2,2,2,2))
	plot(x,y,type="n",xlim=c(min(x),max(x)),ylim=c(-max_y,max_y),xlab="",ylab="",xaxt="n",yaxt="n",main=paste("profile",as.character(data[i,1])," : ",as.numeric(data[i,4])," genes",sep=""),cex.main=7/row_counts,las=2)
	if(data[i,6]<0.05)
	{
		rect(-max_y*2, -max_y*2, 100, 100, col=ddd)
		ddd=ddd+1
	}
	points(x,y,type="l",lwd=7/row_counts*2.5)
	box()
}
dev.off()
