#!/usr/bin/env perl
use warnings;
use strict;
use Getopt::Long;
my %opts;
GetOptions(\%opts, "i=s", "g=s", "h=i", "w=i", "o=s");
my $usage = <<"USAGE";
	Usage:	perl $0 -i <file> -g <group> -o <outprefix> [options]
	Notes:	Need R and gmodels package of R
	Options:
		-i     file        input file
		-g     string      x,y,...(1,1,1,1: 4 group, 1 of each group)
		-o     string      outprefix
		-h     int         image height, default 8
		-w     int         image width, default 10

USAGE

die $usage if(!$opts{i} or !$opts{g} or !$opts{o});
$opts{h}=$opts{h}?$opts{h}:8;
$opts{w}=$opts{w}?$opts{w}:10;

open RCMD, ">$opts{o}.r" or die $!;
print RCMD "
library(gmodels)
all <- read.table(\"$opts{i}\",header = T,row.names=1)
tmp <- matrix(0,nrow = nrow(all), ncol = ncol(all))
for(i in 1:ncol(all)){
	tmp[,i] = all[ ,i]/sum(all[ ,i])
}
colnames(tmp) <- colnames(all)
rownames(tmp) <- rownames(all)
data <- t((tmp))
data.pca <- fast.prcomp(data,retx=T,scale=F,center=T)
a <- summary(data.pca)
tmp <- a[4]\$importance
pro1 <- as.numeric(sprintf(\"%.3f\",tmp[2,1]))*100
pro2 <- as.numeric(sprintf(\"%.3f\",tmp[2,2]))*100
xmax <- max(data.pca\$x[,1])
xmin <- min(data.pca\$x[,1])
ymax <- max(data.pca\$x[,2])
ymin <- min(data.pca\$x[,2])
style <-colnames(all)

xx<-c(\"black\",\"red\",\"chocolate\",\"green\",\"blue\",\"cyan\",\"yellow\",\"mediumpurple\",\"orange\",\"purple\",\"pink\",\"gray\",\"wheat\",\"lightseagreen\",\"violet\",\"darkgray\",\"darkturquoise\")
classify<-unlist(strsplit(\"$opts{g}\",\",\",fix=T))
classify<-as.numeric(as.character(classify))
sample_count<-sum(classify)
sample_colour<-rep(0,sample_count)
cnt<-1
for(i in 1:length(classify))
{
	for(j in 1:classify[i] )
	{
		sample_colour[cnt]<-xx[i]
		cnt<-cnt+1
	}
}

pdf(paste(\"$opts{o}\",\".PCA.pdf\",sep=\"\"),width=$opts{w},height=$opts{h})
plot(data.pca\$x[,1],data.pca\$x[,2],xlab=paste(\"PC1\",\"(\",pro1,\"%)\",sep=\"\"),ylab=paste(\"PC2\",\"(\",pro2,\"%)\",sep=\"\"),main=\"PCA\",cex=0.75,cex.lab=1.2,font.lab=1.5,cex.main=2.0,xlim=c(1.1*xmin,1.1*xmax),ylim=c(1.1*ymin,1.1*ymax),pch=16,col=sample_colour)
text(data.pca\$x[,1],data.pca\$x[,2],labels=style,cex=0.5)

abline(h=0,col=\"grey\")
abline(v=0,col=\"grey\")

z<-cbind(rownames(all),data.pca\$rotation[,1],data.pca\$rotation[,2])
colnames(z)<-c(\"ID\",\"PC1\",\"PC2\")
write.table(z,file=paste(\"$opts{o}\",\".PC_2D.xls\",sep=\"\"),sep=\"\t\", quote=FALSE,row.names=FALSE)
dev.off()
";

`R --restore --no-save < $opts{o}.r`;
