args<-commandArgs(T)
library("stringr")

mydata=read.table(args[1],header=F,sep="\t")
stat=read.table(args[2],header=F,sep="\t")

base = as.numeric(args[3])
h = as.numeric(args[4])
p = c(0,0,0,0)
j <- 1;
cur <- 0

rn <- nrow(stat)
names_len <- max(nchar(as.character(stat[,2])))
bar <- str_c(rep("-",as.integer(names_len / 2) * 1.3 ),collapse='')

colnames(mydata)<-c("x","y")
coln<-c(NA,"5'UTR length (log2)")
pdf(paste(args[1],".pdf",sep=""),width=12,height=10)
par(mar=c(20,8,2,2))
boxplot(y~x,data=mydata,ylab=coln[2],xlab=coln[1],xlim=c(1,rn),names=NA)
#text(0.5,base,labels=bar,srt=60,xpd=TRUE,adj=1,cex=1.5)

for(i in 1:rn){
	if(cur < stat[i,3]){
		text(i-0.5,base,labels=bar,srt=60,xpd=TRUE,adj=1,cex=1.5)
		p[j] <- i - 0.5
		j <- j + 1
	}
	text(i,base,labels=paste(stat[i,2]," (",stat[i,3],")"),srt=60,xpd=TRUE,adj=1)
	cur <- stat[i,3]
}
text(rn+0.5,base,labels=bar,srt=60,xpd=TRUE,adj=1,cex=1.5)
p[j] <- rn + 0.5

text(p[1]+(p[2]-p[1])/2-2,h,labels="biological_process",xpd=TRUE,adj=1)
text(p[2]+(p[3]-p[2])/2-2,h,labels="cellular_component",xpd=TRUE,adj=1)
text(p[3]+(p[4]-p[3])/2-2,h,labels="molecular_function",xpd=TRUE,adj=1)


dev.off()
