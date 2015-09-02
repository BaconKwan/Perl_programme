library("ggplot2")

pathway = read.table("FD9AB-VS-FD1AB.path.xls.xls", sep = "\t", head = T)
pathbar = ggplot(pathway,aes(x=Pathway,y=Gene))
pathbar + geom_bar(stat="identity", aes(fill=Class))
pdf("FD9AB-VS-FD1AB.pdf",height=7.2,width=12.8)
pathbar + geom_bar(stat="identity", width=0.35, aes(fill=Class), position="dodge") + scale_fill_manual(values = c("green", "red")) + theme_bw() + theme(axis.text.x= element_text(angle=60,hjust=1), panel.grid.minor=element_blank(), panel.grid.major.x=element_blank())
dev.off()
