# 18/10/2013
# Juliette AURY-LANDAS

# script permettant d'extraire les snv dans des gènes d'intérêt
# à partir des fichiers EVAnnot annotés par notre pipeline d'annotation à partir des vcf GATK du CNG


## entête fichier de sortie commun à tous les individus
echo -e "individual\tchrom\tgPosStart\tgPosEnd\tref\talt\tFunc.refGene\tGene.refGene\tExonicFunc.refGene\tAAChange.refGene\tLJB2_SIFT\tLJB2_PolyPhen2_HDIV\tLJB2_PP2_HDIV_Pred\tLJB2_PolyPhen2_HVAR	LJB2_PolyPhen2_HVAR_Pred\tLJB2_LRT\tLJB2_LRT_Pred\tLJB2_MutationTaster\tLJB2_MutationTaster_Pred\tLJB_MutationAssessor\tLJB_MutationAssessor_Pred\tLJB2_FATHMM	LJB2_GERP++\tLJB2_PhyloP\tLJB2_SiPhy\tcosmic64\tesp6500si_ea\tesp6500si_all\t1000g2012apr_eur\t1000g2012apr_all\tsnp137\tsnp137NonFlagged\tcytoband\twgRna\tqual\ttotalRead\tusedRead\tallelicBalance\tgenotypeStatus\taUsed\tcUsed\tgUsed\ttUsed\tindelrefUsed\tindelaltUsed" >150Alz_snpOnly_geneListOnly.txt

for file in `ls *EVAnnot`; do ## pour chaque fichier EVAnnot
	## nom individu
	sample=${file/_HG19_SNP.annot.hg19_multianno.EVAnnot/}
	
	## extraction snv + ajout nom individu avant la ligne
	#~ awk -F"\t" '$4~/^A$|^C$|^G$|^T$/ && $5~/^A$|^C$|^G$|^T$/ {print "'"${sample}"'""\t"$0}' $file >$file.snvOnly
	
	## extraction gènes de la liste d'intêret
	#awk -F"\t" 'FNR==NR {a[$1]=1; next;} $8 in a {print $0}' liste_gene_alz.txt $file.snvOnly >>150Alz_snpOnly_geneListOnly.txt
	## extraction des gènes de la liste d'intérêt en tenant compte des annotations multiples (séparées par des , ou ;)
	#awk -F"\t" 'FNR==NR {a[$1]=1; next;} $8 ~ a[/[^|*(;|,)]$8[$|(;|,)*]/] {print $0}' liste_gene_alz.txt $file.snvOnly >>150Alz_snpOnly_geneListOnly.txt
	
	
	while read gene; do
		awk -F"\t" '$8 ~ /(^|.*(;|,))'$gene'($|(;|,|:|\().*)/ {print $0}' $file.snvOnly >>150Alz_snpOnly_geneListOnly.txt
	done < liste_gene_alz.txt
	
done

## gènes non reconnus (pb Gene Symbol)
awk -F"\t" 'FNR==NR {a[$8]=1; next;} !($1 in a) {print $0}' 150Alz_snpOnly_geneListOnly.txt liste_gene_alz.txt >unknown_gene.txt

## suppression variations "intronic"
awk -F"\t" '$7!~/UTR|^intronic$|(up|down)stream|intergenic/ {print $0}' 150Alz_snpOnly_geneListOnly.txt >150Alz_snpOnly_geneListOnly_exonicAndSplicingOnly.txt

