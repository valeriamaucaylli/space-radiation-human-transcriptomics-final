#!/usr/bin/env Rscript
# EXTREME HEALTH 01 — canonical R validation before Results Lock
# Frozen endpoints: ROS, DNA repair, OXPHOS, inflammation.
# Requires: DESeq2, limma, fgsea, jsonlite.

suppressPackageStartupMessages({
  library(DESeq2)
  library(limma)
  library(fgsea)
  library(jsonlite)
})

args <- commandArgs(trailingOnly=TRUE)
base <- if (length(args)>=1) args[[1]] else "."
out <- if (length(args)>=2) args[[2]] else file.path(base,"R_results")
dir.create(out, recursive=TRUE, showWarnings=FALSE)
I <- file.path(base,"inputs")
PATH_ORDER <- c("Oxidative stress (ROS)","DNA repair","Mitochondrial/OXPHOS","Inflammation")

j <- fromJSON(file.path(I,"pathway_sets_2026_1_Hs.json"), simplifyVector=FALSE)
PATHWAYS <- lapply(PATH_ORDER, function(p) unique(unlist(j$pathways[[p]]$ensembl_ids, use.names=FALSE)))
names(PATHWAYS) <- PATH_ORDER

holm <- function(p) p.adjust(p, method="holm")

exact_signflip <- function(x) {
  x <- as.numeric(x); n <- length(x); obs <- abs(mean(x))
  S <- expand.grid(rep(list(c(-1,1)),n))
  vals <- apply(S,1,function(s) abs(mean(x*as.numeric(s))))
  mean(vals >= obs - 1e-12)
}

exact_twogroup <- function(a,b) {
  a<-as.numeric(a); b<-as.numeric(b); z<-c(a,b); n1<-length(a); obs<-abs(mean(a)-mean(b))
  cmb <- combn(seq_along(z),n1)
  vals <- apply(cmb,2,function(ix) abs(mean(z[ix])-mean(z[-ix])))
  mean(vals >= obs - 1e-12)
}

run_fgsea <- function(stats, label, file) {
  stats <- stats[is.finite(stats)]; stats <- sort(stats,decreasing=TRUE)
  set.seed(20261017)
  fg <- fgseaMultilevel(PATHWAYS, stats, minSize=10, maxSize=1000, eps=0)
  fg <- as.data.frame(fg)
  if ("leadingEdge" %in% names(fg)) fg$leadingEdge <- vapply(fg$leadingEdge,paste,character(1),collapse=";")
  fg$p_holm_4 <- holm(fg$pval); fg$analysis <- label
  fg <- fg[match(PATH_ORDER,fg$pathway),]
  write.csv(fg,file,row.names=FALSE)
  fg
}

pathway_sample_scores <- function(expr, sample_names) {
  rows <- list(); k<-1
  for (p in PATH_ORDER) {
    ids <- intersect(PATHWAYS[[p]],rownames(expr))
    sc <- colMeans(expr[ids,sample_names,drop=FALSE])
    rows[[k]] <- data.frame(pathway=p,sample=sample_names,score=as.numeric(sc),n_genes=length(ids)); k<-k+1
  }
  do.call(rbind,rows)
}

# -------- Human astronaut arm --------
cts <- read.csv(gzfile(file.path(I,"counts_13009_filtered.csv.gz")),check.names=FALSE)
rownames(cts)<-cts$gene_id; cts$gene_id<-NULL; cts<-as.matrix(cts); storage.mode(cts)<-"integer"
meta <- read.csv(file.path(I,"metadata_22samples.csv"),stringsAsFactors=FALSE)

run_human <- function(mission, keep_tp, post_tp, pre_tps, label) {
  md <- meta[meta$mission==mission & meta$timepoint %in% keep_tp,]
  rownames(md)<-md$sample
  mm <- cts[,md$sample,drop=FALSE]
  cd <- data.frame(row.names=md$sample,subject=factor(md$subject),condition=factor(ifelse(md$timepoint==post_tp,"post","pre"),levels=c("pre","post")))
  dds <- DESeqDataSetFromMatrix(mm,cd,design=~subject+condition)
  dds <- DESeq(dds,quiet=TRUE)
  res <- results(dds,contrast=c("condition","post","pre"),independentFiltering=FALSE)
  rdf <- as.data.frame(res); rdf$gene_id<-rownames(rdf)
  write.csv(rdf,file.path(out,paste0(label,"_DESeq2_gene_results.csv")),row.names=FALSE)
  run_fgsea(res$stat,label,file.path(out,paste0(label,"_fgsea_Wald.csv")))

  vs <- assay(varianceStabilizingTransformation(dds,blind=FALSE))
  rows<-list(); k<-1
  for (p in PATH_ORDER) {
    ids<-intersect(PATHWAYS[[p]],rownames(vs)); vals<-c(); labs<-c()
    for (s in unique(md$subject)) {
      sm<-md[md$subject==s,]; pre<-sm$sample[sm$timepoint %in% pre_tps]; post<-sm$sample[sm$timepoint==post_tp]
      if (length(pre)>=1 && length(post)==1) {
        vals<-c(vals,mean(vs[ids,post])-mean(vs[ids,pre,drop=FALSE])); labs<-c(labs,s)
      }
    }
    rows[[k]]<-data.frame(analysis=label,pathway=p,n_subjects=length(vals),n_genes=length(ids),mean_delta=mean(vals),p_exact=exact_signflip(vals),subject_deltas=paste(paste0(labs,":",sprintf("%.6f",vals)),collapse=";")); k<-k+1
  }
  z<-do.call(rbind,rows); z$p_holm_4<-holm(z$p_exact)
  write.csv(z,file.path(out,paste0(label,"_confirmatory_pathway_scores.csv")),row.names=FALSE)
}

run_human("Inspiration4",c("L-92","L-44","L-3","R+1"),"R+1",c("L-92","L-44","L-3"),"I4_Rplus1_vs_mean_pre")
run_human("Axiom_Ax1",c("L-2wk","R+24h"),"R+24h",c("L-2wk"),"Ax1_Rplus24h_vs_Lminus2wk")

# -------- GSE218935: deposited raw counts, 3 vs 3 --------
g <- read.delim(gzfile(file.path(I,"GSE218935_BulkRNAseq_counts_DEG.txt.gz")),check.names=FALSE,stringsAsFactors=FALSE)
rownames(g)<-g$gene_id
s1<-c("h1G_0720","h1G_0807","h1G_0810"); su<-c("uG_0720","uG_0807","uG_0810")
gm<-as.matrix(g[,c(s1,su)]); storage.mode(gm)<-"integer"
cd<-data.frame(row.names=c(s1,su),condition=factor(c(rep("oneG",3),rep("uG",3)),levels=c("oneG","uG")))
dds<-DESeq(DESeqDataSetFromMatrix(gm,cd,design=~condition),quiet=TRUE)
res<-results(dds,contrast=c("condition","uG","oneG"),independentFiltering=FALSE)
rdf<-as.data.frame(res); rdf$gene_id<-rownames(rdf); write.csv(rdf,file.path(out,"GSE218935_DESeq2_rerun.csv"),row.names=FALSE)
run_fgsea(res$stat,"GSE218935_uG_vs_1G",file.path(out,"GSE218935_fgsea_Wald.csv"))
# direct concordance with deposited DESeq2 columns
ix<-intersect(rownames(rdf),rownames(g)); cc<-cor(rdf[ix,"stat"],g[ix,"stat.uG_vs_oneG"],use="pairwise.complete.obs",method="spearman")
write.csv(data.frame(comparison="rerun_vs_deposited_DESeq2_Wald",spearman_rho=cc),file.path(out,"GSE218935_DESeq2_concordance.csv"),row.names=FALSE)

# -------- OSD-993: four 4-Gy modalities vs matched shams --------
c993<-read.csv(file.path(I,"GLDS-805_rna_seq_STAR_Unnormalized_Counts_GLbulkRNAseq.csv"),check.names=FALSE)
rownames(c993)<-c993[[1]]; c993<-as.matrix(c993[,-1]); storage.mode(c993)<-"integer"
s993<-read.csv(file.path(I,"GLDS-805_rna_seq_SampleTable_GLbulkRNAseq.csv"),check.names=FALSE,stringsAsFactors=FALSE)
names(s993)[1]<-"sample"
run_two_group_deseq <- function(counts, exp_samples, ctl_samples, label) {
  ss<-c(ctl_samples,exp_samples); mm<-counts[,ss,drop=FALSE]
  cd<-data.frame(row.names=ss,condition=factor(c(rep("control",length(ctl_samples)),rep("exposed",length(exp_samples))),levels=c("control","exposed")))
  dds<-DESeq(DESeqDataSetFromMatrix(mm,cd,design=~condition),quiet=TRUE)
  res<-results(dds,contrast=c("condition","exposed","control"),independentFiltering=FALSE)
  rdf<-as.data.frame(res); rdf$gene_id<-rownames(rdf); write.csv(rdf,file.path(out,paste0(label,"_DESeq2_gene_results.csv")),row.names=FALSE)
  run_fgsea(res$stat,label,file.path(out,paste0(label,"_fgsea_Wald.csv")))
  vs<-assay(varianceStabilizingTransformation(dds,blind=FALSE)); rows<-list();k<-1
  for(p in PATH_ORDER){ids<-intersect(PATHWAYS[[p]],rownames(vs)); a<-colMeans(vs[ids,exp_samples,drop=FALSE]);b<-colMeans(vs[ids,ctl_samples,drop=FALSE]);rows[[k]]<-data.frame(analysis=label,pathway=p,n_genes=length(ids),mean_delta=mean(a)-mean(b),p_exact=exact_twogroup(a,b));k<-k+1}
  z<-do.call(rbind,rows);z$p_holm_4<-holm(z$p_exact);write.csv(z,file.path(out,paste0(label,"_confirmatory_pathway_scores.csv")),row.names=FALSE)
}
cond<-s993$condition; names(cond)<-s993$sample
charged_ctl<-names(cond)[grepl("^non.irradiated.*charged",cond)]
gamma_ctl<-names(cond)[grepl("^non.irradiated.*gamma",cond)]
run_two_group_deseq(c993,names(cond)[grepl("^proton",cond)],charged_ctl,"OSD993_Proton_4Gy")
run_two_group_deseq(c993,names(cond)[grepl("^Si.28",cond)],charged_ctl,"OSD993_Si28_4Gy")
run_two_group_deseq(c993,names(cond)[grepl("^Fe.56",cond)],charged_ctl,"OSD993_Fe56_4Gy")
run_two_group_deseq(c993,names(cond)[grepl("^cesium.137",cond)],gamma_ctl,"OSD993_Cs137_gamma_4Gy")

# -------- OSD-577: 0.5-Gy simplified GCRsim, 24 h and 6 d kept separate --------
c577<-read.csv(file.path(I,"GLDS-571_rna_seq_STAR_Unnormalized_Counts_GLbulkRNAseq.csv"),check.names=FALSE)
rownames(c577)<-c577[[1]]; c577<-as.matrix(c577[,-1]); storage.mode(c577)<-"integer"
s577<-read.csv(file.path(I,"GLDS-571_rna_seq_SampleTable_GLbulkRNAseq.csv"),check.names=FALSE,stringsAsFactors=FALSE);names(s577)[1]<-"sample"
co<-s577$condition;names(co)<-s577$sample
for(model in c("Mature.Model","Angiogenesis.Model")){
  exp<-names(co)[grepl("mixed.radiation...No.treatment",co,fixed=TRUE)&grepl(model,co,fixed=TRUE)]
  ctl<-names(co)[grepl("sham.irradiated...No.treatment",co,fixed=TRUE)&grepl(model,co,fixed=TRUE)]
  lab<-if(model=="Mature.Model")"OSD577_Mature_GCRsim0.5Gy" else "OSD577_Angiogenesis_GCRsim0.5Gy"
  run_two_group_deseq(c577,exp,ctl,lab)
}

# -------- OSD-129: paired 2x2 microarray; limma moderated t --------
r129<-read.csv(file.path(I,"GLDS-129_array_raw_intensities_GLmicroarray.csv"),check.names=FALSE,stringsAsFactors=FALSE)
d129<-read.csv(file.path(I,"OSD129_design_manifest.csv"),stringsAsFactors=FALSE)
keep<-!is.na(r129$ENSEMBL)&r129$count_ENSEMBL_mappings==1
rr<-r129[keep,]; samples<-d129$sample
M<-as.matrix(rr[,samples]);storage.mode(M)<-"double"
Q<-normalizeBetweenArrays(M,method="quantile"); L<-log2(pmax(Q,1e-12))
# Collapse replicate probes to Ensembl mean
spl<-split(seq_len(nrow(L)),rr$ENSEMBL)
G<-t(vapply(spl,function(ix) colMeans(L[ix,,drop=FALSE]),numeric(ncol(L))))
colnames(G)<-samples
md<-d129[match(samples,d129$sample),];md$donor<-factor(md$donor);md$rad<-as.integer(md$radiation=="IR");md$ug<-as.integer(md$gravity=="uG")
design<-model.matrix(~donor+rad*ug,data=md)
fit<-eBayes(lmFit(G,design))
cn<-colnames(design)
# contrast vectors in coefficient space
cvec<-function(rad=0,ug=0,int=0){z<-rep(0,length(cn));names(z)<-cn;z["rad"]<-rad;z["ug"]<-ug;z["rad:ug"]<-int;z}
Cs<-list(Radiation_at_1G=cvec(rad=1),Microgravity_noIR=cvec(ug=1),Interaction_Radiation_x_Microgravity=cvec(int=1),Radiation_at_uG=cvec(rad=1,int=1),Microgravity_with_IR=cvec(ug=1,int=1),Combined_uG_IR_vs_1G_NoIR=cvec(rad=1,ug=1,int=1))
for(nm in names(Cs)){
  C<-matrix(Cs[[nm]],ncol=1);rownames(C)<-cn;colnames(C)<-nm
  ff<-eBayes(contrasts.fit(lmFit(G,design),C)); tt<-topTable(ff,coef=1,number=Inf,sort.by="none");tt$gene_id<-rownames(tt);write.csv(tt,file.path(out,paste0("OSD129_",nm,"_limma_gene_results.csv")),row.names=FALSE)
  st<-ff$t[,1];names(st)<-rownames(G);run_fgsea(st,paste0("OSD129_",nm),file.path(out,paste0("OSD129_",nm,"_fgsea_limma_t.csv")))
}

writeLines(c(capture.output(sessionInfo())),file.path(out,"sessionInfo.txt"))
message("Canonical R validation completed: ",out)
