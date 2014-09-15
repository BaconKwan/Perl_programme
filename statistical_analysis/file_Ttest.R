args<-commandArgs(T)
data <- read.table(args[1],header = T,sep="\t")
split<-args[2]              #### split  means fisrt treatment last expression's column number
control<-data[,1:split]
split1=as.numeric(split)+1   #### split1 means second treatment first expression's column number
case<-cbind(data[,1],data[,split1:ncol(data)])
Pvalue<-c(rep(0,nrow(data)))
control_mean<-c(rep(0,nrow(data)))
case_mean<-c(rep(0,nrow(data)))
log2_FC<-c(rep(0,nrow(data)))
for(i in 1:nrow(data))
{
	if( (is.na(var(as.numeric(control[i,2:ncol(control)]))) && is.na(var(as.numeric(case[i,2:ncol(case)])))) || (var(as.numeric(control[i,2:ncol(control)]))==0 && var(as.numeric(case[i,2:ncol(case)]))==0))
	{
		Pvalue[i]<-1
	}
	else
	{
		y<-t.test(as.numeric(control[i,2:ncol(control)]),as.numeric(case[i,2:ncol(case)]),alternative="two.sided")
		Pvalue[i]<-y$p.value
	}
	control_mean[i]<-mean(as.numeric(control[i,2:ncol(control)]))
	case_mean[i]<-mean(as.numeric(case[i,2:ncol(case)]))
	log2_FC[i]<-log2(case_mean[i]/control_mean[i])
}
fdr<-p.adjust(Pvalue,method="fdr",length(Pvalue))
out<-cbind(data,control_mean,case_mean,log2_FC,Pvalue,fdr)
FC="log2_FC(case_mean/control_mean)"
title=colnames(out)
title[ncol(data)+3]=FC
colnames(out)=title
write.table(out,file=paste(args[1],"Ttest.xls",sep="."),quote=FALSE,row.names=FALSE,sep="\t")
