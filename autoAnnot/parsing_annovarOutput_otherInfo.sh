#!/bin/bash
#
# Sophie COUTANT
# 23/07/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# This script allows the parsing of the otherinfo column from the annovar output to generate a standard input for EVA                                        #
#                                                                                                                                                            #
# a- Extract the wanted columns using vcf-query from vcf-tools                                                                                               #
# b- Write the extracted colums as tab separated                                                                                                             #
# c- Split 'allelicDepth' and replace 'ref' 'alt' with -> 'aUsed' 'cUsed' 'gUsed' 'tUsed' 'indelRefUsed' 'indelAltUsed'                                      #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# usage
function usage
{
    echo "USAGE: parsing_annovarOutput_otherInfo.sh -f <file> -c <CASAVA/GATK/Samtools>"
    echo "       -f <multianno.txt file to parse>"
    echo "       -c <CASAVA/GATK/Samtools> (variant calling tool used to produce the variant calling file)"
    echo "EXAMPLE: ./parsing_annovarOutput_otherInfo.sh -f Project/Annotated/Sample1_multianno.txt -c GATK"
}

# get the arguments of the command line
if [ $# -lt 2 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-f | --fileName )         shift
					if [ "$1" != "" ]; then
						file=$1 #file (complete path+extention)
					else
						usage
						exit
					fi
		                        ;;
		-c | --caller )         shift
					if [ "$1" != "" ]; then						
						caller=$1 #caller used for variant calling
					else
						usage
						exit
					fi
		                        ;;		                        
		                        
		*)           		usage
		                        exit
		                        ;;
	    esac
	    shift
	done
fi

fileName=${file%.*} #nom du fichier+Path sans sa dernière extension (ici: .vcf)
sample=$(basename $fileName) #nom du fichier sans path et sans extention
path=$(dirname $fileName) #nom du path, sans le fichier

#get Otherinfo column number;
otherInfoNbCol=$(head -n 1 $file | awk '{ for(i;i<=NF;i++){ if ($i ~ /Otherinfo/) { print i } }}';)

#Récupérer le header correspondant au nom de colonne du fichier vcf de $fileName de départ
#~ header=$(grep "#CHROM" $file);
header="#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	$sample"

#Extraire toutes les colonnes avant OtherInfo et les coller dans un nouveau fichier 'multiannoOnly'
cut -f1-$(($otherInfoNbCol-1)) $file > $fileName"Only.txt"

#Extraire toutes les colonnes Otherinfo et les coller dans un nouveau fichier 'extract vcflike'
cut -f$otherInfoNbCol- $file | sed -e 's/Otherinfo/'"$header"'/g' > $fileName"Extract.vcflike"

if [[ $caller = "GATK" ]]; 
then

	#-------------Parse GATK OtherInfo-----------------------#
	echo -e "\t   #CALLER: GATK"
	echo -e "\t    a- Extract the wanted columns using vcf-query from vcf-tools (QUAL INFO/DP FORMAT/DP:AB:GTR:GQ:AD)"

	#Tabuler les informations souhaitées : grace a vcf-query
	awk 'BEGIN {OFS="\t"} BEGIN { print "qual","totalRead","usedRead","allelicBalance","genotypeStatus","GQ","allelicDepth"}' > $fileName"_extractedOtherinfo.txt"
	export PERL5LIB=/opt/vcftools_0.1.11/perl
	echo "	    #CMD: vcf-query $fileName"Extract.vcflike" -f '%QUAL\t%INFO/DP\t[%DP\t%AB\t%GTR\t%GQ\t%AD]\n'"
	vcf-query $fileName"Extract.vcflike" -f '%QUAL\t%INFO/DP\t[%DP\t%AB\t%GTR\t%GQ\t%AD]\n' >> $fileName"_extractedOtherinfo.txt"

	#Fusionner le multiannoOnly et le extractedOtherinfo
	echo -e "\t    b- Write the extracted colums as tab separated"
	paste $fileName"Only.txt" $fileName"_extractedOtherinfo.txt" > $fileName"_TabSep.txt"

	#totalRead = InfoDP
	#usedRead = FormatDP
	#allelicBalance = AB
	#ACGT = split "allelicDepth" and transform "ref" "alt" in -> "aUsed" "cUsed" "gUsed" "tUsed" "indelRefUsed" "indelAltUsed"
	echo -e "\t    c- Split 'allelicDepth' and replace 'ref' 'alt' with -> 'aUsed' 'cUsed' 'gUsed' 'tUsed' 'indelRefUsed' 'indelAltUsed'"
	#Recupère toute la colonne Ref sans l'en tête
	Ref=$(awk -F'\t' 'BEGIN {OFS="\t" ; FS="\t"} { for(i;i<=NF;i++){ if ($i ~ /Ref/) { Ref=i } }} { if ($Ref !~ /Ref/) print $Ref}' $fileName"_TabSep.txt")
	#Recupère toute la colonne Alt sans l'en tête
	Alt=$(awk -F'\t' 'BEGIN {OFS="\t" ; FS="\t"}{ for(i;i<=NF;i++){ if ($i ~ /Alt/) { Alt=i } }} { if ($Alt !~ /Alt/) print $Alt}' $fileName"_TabSep.txt")
	#Recupère toute la colonne allelicDepth sans l'en tête
	allelicDepth=$(awk -F'\t' 'BEGIN {OFS="\t" ; FS="\t"}{ for(i;i<=NF;i++){ if ($i ~ /allelicDepth/) { allelicDepth=i } }} { if ($allelicDepth !~ /allelicDepth/) print $allelicDepth}' $fileName"_TabSep.txt")

	echo "$Ref" > $path/Ref.txt
	echo "$Alt" > $path/Alt.txt
	echo "$allelicDepth" > $path/allelicDepth.txt
	paste $path/Ref.txt $path/Alt.txt $path/allelicDepth.txt > $path/RefAlt.txt

	awk -F'\t|,' 'BEGIN {OFS="\t"} BEGIN {print "aUsed","cUsed","gUsed","tUsed","indelRefUsed","indelAltUsed"} {
		if ($1 == "A" && $2 == "C") { print $3,$4,".",".",".","." } 
		else if ($1 == "A" && $2 == "G") { print $3,".",$4,".",".","." } 
		else if ($1 == "A" && $2 == "T") { print $3,".",".",$4,".","." } 
		else if ($1 == "C" && $2 == "A") { print $4,$3,".",".",".","." } 
		else if ($1 == "C" && $2 == "G") { print ".",$3,$4,".",".","." } 
		else if ($1 == "C" && $2 == "T") { print ".",$3,".",$4,".","." } 
		else if ($1 == "G" && $2 == "A") { print $4,".",$3,".",".","." }
		else if ($1 == "G" && $2 == "C") { print ".",$4,$3,".",".","." }
		else if ($1 == "G" && $2 == "T") { print ".",".",$3,$4,".","." }
		else if ($1 == "T" && $2 == "A") { print $4,".",".",$3,".","." }
		else if ($1 == "T" && $2 == "C") { print ".",$4,".",$3,".","." }
		else if ($1 == "T" && $2 == "G") { print ".",".",$4,$3,".","." }
		else { print ".",".",".",".",$3,$4 } #Indel
		
	}' $path/RefAlt.txt > $path/ACGT.txt
 
	#Supprimer la colonne "allelicDepth" et la remplacer par les colonnes "aUsed","cUsed","gUsed","tUsed","indelRefUsed","indelAltUsed" du fichier ACGT.txt
	awk -F'\t' 'sub(FS $NF,x)' $fileName"_TabSep.txt" > $fileName"_TabSep-LastCol.txt"
	paste $fileName"_TabSep-LastCol.txt" $path/ACGT.txt > $fileName"_TabSep_ACGT.txt"

	#-------------END of Parse GATK OtherInfo-----------------------#

	#Suppression fichiers devenus inutiles
	rm $fileName"Only.txt"
	rm $fileName"Extract.vcflike"
	rm $fileName"_extractedOtherinfo.txt"
	rm $fileName"_TabSep.txt"
	rm $fileName"_TabSep-LastCol.txt"
	rm $path/Ref.txt
	rm $path/Alt.txt 
	rm $path/allelicDepth.txt
	rm $path/RefAlt.txt 
	rm $path/ACGT.txt
	
elif [[ $caller = "CASAVA" ]];
then
	#-------------Parse CASAVA OtherInfo-----------------------#
	echo -e "\t   #CALLER: CASAVA"
	echo -e "\t    a- Extract the wanted columns using vcf-query from vcf-tools (QUAL INFO/DP INFO/Q_snp INFO/A_used INFO/C_used INFO/G_used INFO/T_used INFO/alt_reads INFO/indel_reads FORMAT/DP:GTR:GQ)"

	#Tabuler les informations souhaitées : grace a vcf-query
	awk 'BEGIN {OFS="\t"} BEGIN { print "qual","totalRead","Qsnp","aUsed","cUsed","gUsed","tUsed", "indelRefUsed","indelAltUsed", "usedRead","genotypeStatus","GQ"}' > $fileName"_extractedOtherinfo.txt"
	export PERL5LIB=/opt/vcftools_0.1.11/perl
	echo "	    #CMD: vcf-query $fileName"Extract.vcflike" -f '%QUAL\t%INFO/DP\t%INFO/Q_snp\t%INFO/A_used\t%INFO/C_used\t%INFO/G_used\t%INFO/T_used\t%INFO/alt_reads\t%INFO/indel_reads\t[%DP\t%GTR\t%GQ]\n'"
	vcf-query $fileName"Extract.vcflike" -f '%QUAL\t%INFO/DP\t%INFO/Q_snp\t%INFO/A_used\t%INFO/C_used\t%INFO/G_used\t%INFO/T_used\t%INFO/alt_reads\t%INFO/indel_reads\t[%DP\t%GTR\t%GQ]\n' >> $fileName"_extractedOtherinfo.txt"
	
	#Fusionner le multiannoOnly et le extractedOtherinfo
	echo -e "\t    b- Write the extracted colums as tab separated"
	paste $fileName"Only.txt" $fileName"_extractedOtherinfo.txt" > $fileName"_TabSep_ACGT.txt"
	
	#-------------END of Parse CASAVA OtherInfo-----------------------#

	#Suppression fichiers devenus inutiles
	rm $fileName"Only.txt"
	rm $fileName"Extract.vcflike"
	rm $fileName"_extractedOtherinfo.txt"

else
	echo -e "\t    Only CASAVA or GATK variant calling files supported !"
fi
