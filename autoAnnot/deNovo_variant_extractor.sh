# 08/10/2013
# Juliette AURY-LANDAS (IntegraGen)

# 04/01/2014
# Sophie COUTANT (EVAnnot)

# script permettant la soustraction différentielle des variants présents chez les parents (002 et 003) => identification de variants de novo chez le cas index (001)
# à partir des fichiers txt annotés par Integragen ou bien des fichier EVAnnot annoté par Annovar

#--------------------------INTEGRAGEN----------------------------------#
# extraction des champs d'intérêt pour la comparaison de fichier
# création d'un fichier chr.pos:ref
# si V4+UTR
awk -F"\t" '{print $2"."$1":"$11}' snp.txt >snp.CHR.POS.REF
awk -F"\t" '{print $2"."$1":"$12}' indel.txt >indel.CHR.POS.REF
# si V5
awk -F"\t" '{print $2"."$1":"$14}' snp.txt >snp.CHR.POS.REF
awk -F"\t" '{print $2"."$1":"$14}' indel.txt >indel.CHR.POS.REF

# création d'un fichier chr.pos:ref + tous les champs initiaux
# si V4+UTR
awk -F"\t" '{print $2"."$1":"$11"\t"$0}' snp.txt >snp.CHR.POS.REF_all
awk -F"\t" '{print $2"."$1":"$12"\t"$0}' indel.txt >indel.CHR.POS.REF_all
# si V5
awk -F"\t" '{print $2"."$1":"$14"\t"$0}' snp.txt >snp.CHR.POS.REF_all
awk -F"\t" '{print $2"."$1":"$14"\t"$0}' indel.txt >indel.CHR.POS.REF_all

# pour les snp
# soustraction différentielle des variants présents chez les parents
diff 002.snp.CHR.POS.REF 001.snp.CHR.POS.REF |grep ">" |uniq > 001.snp.CHR.POS.REF_NotIn002.UNIQ #variants non présents chez la mère 002
sed -e 's/> //g' 001.snp.CHR.POS.REF_NotIn002.UNIQ >001.snp.CHR.POS.REF_NotIn002.UNIQ2 #suppression du >
diff 003.snp.CHR.POS.REF 001.snp.CHR.POS.REF_NotIn002.UNIQ2 |grep ">" |uniq > 001.snp.CHR.POS.REF_NotIn002And003.UNIQ #variants non présents chez la mère 002 et chez le père 003
sed -e 's/> //g' 001.snp.CHR.POS.REF_NotIn002And003.UNIQ >001.snp.CHR.POS.REF_NotIn002And003.UNIQ2 #suppression du >

# extraction des informations sur les variants de novo identifiés
awk -F"\t" 'FNR==NR {a[$1]=1; next;} $1 in a {print $0}' 001.snp.CHR.POS.REF_NotIn002And003.UNIQ2 001.snp.CHR.POS.REF_all > 001.snp_NotIn002And003.txt

# idem pour les indels

# ajout des entêtes
# snp
sed -i '1ichrom.position:ref\tposition\tchrom\tsample.ID\trs.name\tpolyphen\thapmap_ref_other\tX1000Genomes.AllObs\tX1000Genomes.AF\tEVS.AllObs\tEVS.AF\tEVS.ClinicalInfo\tIG.HTZ.Percent\tIG.Hom.Percent\tref\tA\tC\tG\tT\tused\tfilt\tQ.snp.\tmax_gt\tQ.max_gt.\tstatut\tGene.name\tGene.start\tGene.end\tstrand\tnbre.exon\trefseq\ttypeannot\ttype.pos\tindex.cdna\tindex.prot\tTaille.cdna\tStart\tEnd\tcodon.wild\taa.wild\tcodon.mut\taa.mut\tcds.wild\tcds.mut\tprot.wild\tprot.mut\tmirna\tregion.splice.intron\tregion.splice.exon' 001.snp_NotIn002And003.txt
# indel
sed -i '1ichrom.position:ref.indel\tposition\tchrom\tsample.ID\trs.dbsnp\tobs.dbsnp\tstrand.dbsnp\thapmap_ref_other\t1000Genomes.AllObs\t1000Genomes.AF\tIG.HTZ.Percent\tIG.Hom.Percent\tCIGAR\tref_upstream\tref.indel\tref_downstream\tQ.indel.\tmax_gtype\tQ.max_gtype.\tdepth\talt_reads\tindel_reads\tother_reads\trepeat_unit\tref_repeat_count\tindel_repeat_count\tGene.name\tGene.start\tGene.end\tstrand\tnbre.exon\trefseq\ttype\ttype.pos\tStart\tEnd\tregion.splice.intron\tregion.splice.exon' 001.indel_NotIn002And003.txt


#------------------------------EVAnnot----------------------------------#
# extraction des champs d'intérêt pour la comparaison de fichier
# création d'un fichier chr.pos1-pos2:ref/alt
awk -F"\t" '{print $1"."$2"-"$3":"$4"/"$5}' sample-001_L00x_casava2vcf.hg19_multianno.EVAnnot > sample-001.CHR-POS-REF
awk -F"\t" '{print $1"."$2"-"$3":"$4"/"$5}' sample-002_L00x_casava2vcf.hg19_multianno.EVAnnot > sample-002.CHR-POS-REF
awk -F"\t" '{print $1"."$2"-"$3":"$4"/"$5}' sample-003_L00x_casava2vcf.hg19_multianno.EVAnnot > sample-003.CHR-POS-REF

# création d'un fichier chr.pos1-pos2:ref/alt + tous les champs initiaux pour pouvoir récupérer les annotations
awk -F"\t" '{print $1"."$2"-"$3":"$4"/"$5"\t"$0}' sample-001_L00x_casava2vcf.hg19_multianno.EVAnnot > sample-001.CHR-POS-REF_all
#~ awk -F"\t" '{print $1"."$2"-"$3":"$4"/"$5"\t"$0}' sample-002_L00x_casava2vcf.hg19_multianno.EVAnnot > sample-002.CHR-POS-REF_all
#~ awk -F"\t" '{print $1"."$2"-"$3":"$4"/"$5"\t"$0}' sample-003_L00x_casava2vcf.hg19_multianno.EVAnnot > sample-003.CHR-POS-REF_all


# soustraction différentielle des variants présents chez les parents
diff sample-002.CHR-POS-REF sample-001.CHR-POS-REF | grep ">" | uniq > sample-001.CHR-POS-REF.NotIn002-UNIQ #variants non présents chez la mère 002
sed -e 's/> //g' sample-001.CHR-POS-REF.NotIn002-UNIQ > sample-001.CHR-POS-REF.NotIn002-UNIQ2 #suppression du >
diff sample-003.CHR-POS-REF sample-001.CHR-POS-REF.NotIn002-UNIQ2 | grep ">" | uniq > sample-001.CHR-POS-REF.NotIn002And003.UNIQ #variants non présents chez la mère 002 et chez le père 003
sed -e 's/> //g' sample-001.CHR-POS-REF.NotIn002And003.UNIQ > sample-001.CHR-POS-REF.NotIn002And003.UNIQ2 #suppression du >

# extraction des informations sur les variants de novo identifiés
awk -F"\t" 'FNR==NR {a[$1]=1; next;} $1 in a {print $0}' sample-001.CHR-POS-REF.NotIn002And003.UNIQ2 sample-001.CHR-POS-REF_all > sample-001_NotIn002And003.txt.temp

# ajout des entêtes
head -n 1 sample-001.CHR-POS-REF_all > header.txt
cat header.txt sample-001_NotIn002And003.txt.temp > sample-001_NotIn002And003.txt

#Filtre "Intronic"
awk -F"\t" '$7!~/UTR|^intronic$|(up|down)stream|intergenic/ {print $0}' sample-001_NotIn002And003.txt > sample-001_NotIn002And003_exonicAndSplicingOnly.txt

# pour trouver les variations communes 1 solution :
join sample-001.CHR-POS-REF sample-002.CHR-POS-REF > Common_sample-001Andsample-002.CHR-POS-REF #Attention au tri !
#ou
perl -ne 'print if ($seen{$_} .= @ARGV) =~ /10$/'  sample-001.CHR-POS-REF sample-002.CHR-POS-REF > Common_sample-001Andsample-002.CHR-POS-REF # plus souple (mieux!)
