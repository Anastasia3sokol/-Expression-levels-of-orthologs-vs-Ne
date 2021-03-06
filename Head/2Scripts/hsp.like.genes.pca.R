rm(list=ls(all=TRUE))

genes <- read.table('../../Body/1_Raw/gencode.v25.annotation.gtf.Genes.Shet.pLI.FIS.RVIS.GHIS.KnKs.GC.BrainSpecificRanking.Branch', header = 1)

HSP_id <- 'ENSG00000096384'

genes_num_cols <- genes[, -c(3,4,5,7, 18)] #18 столбец - это "BrainSpecificRanking", убираем его так как у HSP90 там нет начения

nas <- summary(genes_num_cols)[7,] #очень много пропущенных наченией в скорах
genes_without_na <- na.omit(genes_num_cols) #остается 2435 генов из 58037. 
length(unique(genes_without_na$EnsemblId)) # 11536 >> 2435 KOSTYA
DuplGenes = genes_without_na[duplicated(genes_without_na$EnsemblId),]$EnsemblId # ENSG00000167393 ENSG00000168939 ENSG00000182378 ENSG00000198223
genes_without_na = genes_without_na[!genes_without_na$EnsemblId %in% DuplGenes,] # 11532

genes_pca <- prcomp(genes_without_na[,-c(1,2)], scale. = T)
#plot(genes_pca)

pdf('../../Body/4_Figures/hsp.like.genes.pca.pdf')
biplot(genes_pca, choices = 1:2, pc.biplot = F, col = c('white', 'black'), cex = 0.6, main = 'PCA HSP like genes', xlim = c(-0.08,0.08), xlab = 'PC1 (24% explaned var.)', ylab = 'PC2 (13.4% explaned var.)' ) # очень клевая картинка!!!!

biplot(genes_pca, choices = 2:3, pc.biplot = F, col = c('white', 'black'), cex = 0.6, main = 'PCA HSP like genes', xlim = c(-0.08,0.08))

plot(genes_PC$PC1, genes_PC$PC2, col = 'darkslategray3', xlab = 'PC1 (24% explaned var.)', ylab = 'PC2 (13.4% explaned var.)', main = 'Subset of genes similar to HSP90', asp = 1)
points(genes_like_hsp$PC1, genes_like_hsp$PC2, col = 'red')
points(genes_like_hsp[genes_like_hsp$EnsemblId == HSP_id,'PC1'], genes_like_hsp[genes_like_hsp$EnsemblId == HSP_id,'PC2'], col = 'black', pch = '*')
legend(x = 2, y = 11, legend = c('All genes', 'Subset of genes closed \n to hsp90', 'hsp90'), col = c('darkslategray3', 'red', 'black'), pch = c('o', 'o', '*'))

dev.off()

PC1 <- predict(genes_pca)[,1]
PC2 <- predict(genes_pca)[,2]
PC1_var <- summary(genes_pca)$importance[2]
PC2_var <- summary(genes_pca)$importance[5]
genes_labels <- genes_without_na[,c(1,2)]

genes_PC <- data.frame(genes_labels, PC1, PC2)
HspPc1 <- genes_PC[genes_PC$EnsemblId == HSP_id, 3]
HspPc2 <- genes_PC[genes_PC$EnsemblId == HSP_id, 4]
# PC1 у HSP90 равна 2.646849, PC2 у HSP90 равна 1.017779. Как теперь отобрать белки с бликим начением PC1 и PC2. 
# надо найти 300 генов - которые в маленьком кружке с центром - Hsp90 и в идеале проранжировать их по степени схожести (надо повторить геометрию - расстояние между точками...)

genes_PC$distance_to_hsp <- sqrt((HspPc1-genes_PC$PC1)**2 + (HspPc2-genes_PC$PC2)**2)
genes_like_hsp <- genes_PC[order(genes_PC$distance_to_hsp),]
write.table(genes_like_hsp, '../../Body/2_Derived/hsp.like.genes.pca.genes.ranged.by.distance.to.hsp.txt')



