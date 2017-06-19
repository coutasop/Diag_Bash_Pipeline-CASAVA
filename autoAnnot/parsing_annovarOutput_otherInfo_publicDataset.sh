#!/bin/bash
#
# Juliette AURY-LANDAS
# 16/09/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# This script allows the parsing of the otherinfo column from the annovar output to generate a standard input for EVA                                        #
#                                                                                                                                                            #
# a- Extract the wanted columns using vcf-query from vcf-tools                                                                                               #
# b- Write the extracted colums as tab separated                                                                                                             #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# usage
function usage
{
    echo "USAGE: parsing_annovarOutput_otherInfo_publicDataset.sh -d <directory> -t <1K/ESP/dbSNP>"
    echo "       -d <annovar output directory containing multianno.txt files>"
    echo "       -t <1K/ESP/dbSNP> (data type of variant calling file)"
    echo "EXAMPLE: ./parsing_annovarOutput_otherInfo_publicDataset.sh -d Project/Annotated -t 1K"
}

#grep "VT=SV" ALL.wgs.phase1_release_v3.20101123.snps_indels_sv.sites.vcf >ALL.wgs.phase1_release_v3.20101123.sv.sites.vcf
#grep -v "VT=SV" ALL.wgs.phase1_release_v3.20101123.snps_indels_sv.sites.vcf >ALL.wgs.phase1_release_v3.20101123.snps_indels.sites.vcf 
#split -l 5000000 -d ALL.wgs.phase1_release_v3.20101123.snps_indels.sites.vcf

# get the arguments of the command line
if [ $# -lt 4 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-d | --format )         shift
					if [ "$1" != "" ]; then
						# multianno.txt directory
						directory=$1
					else
						usage
						exit
					fi
		                        ;;

		-t | --type )    	shift
					if [ "$1" != "" ]; then
						type=$1
						if [[ $type = "1K" ]]; then
							echo -e "\t   #TYPE: 1000 genomes data"
	
						elif [[ $type = "ESP" ]]; then
							echo -e "\t   #TYPE: ESP data"
							
						elif [[ $type = "dbSNP" ]]; then
							echo -e "\t   #TYPE: dbSNP data"

						elif [[ $type = "exome" ]]; then
							echo "Script error, please contact the author !"
							exit
							
						else
							echo "Only 1000 genomes, ESP, dbSNP variant calling files supported !"
							usage
							exit
						fi
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

#Get the path of the scripts that will be launched
chemin_script=$(dirname $0)

echo -e "\t TIME: BEGIN PARSING ".`date`
for multianno in `ls $directory/*multianno.txt`; do #pour chaque fichier multianno.txt contenu dans le répertoire

	fileName=${multianno%.*} #nom du fichier sans sa dernière extension (ici: .txt)

	echo -e "\n\t#FILE: $multianno:"
	
	#otherInfo Parsing
	echo -e "\t 1- Parsing of the OtherInfo column"

	#~ fileName=${file%.*} #nom du fichier+Path sans sa dernière extension (ici: .vcf)
	sample=$(basename $fileName) #nom du fichier sans path et sans extention
	path=$(dirname $fileName) #nom du path, sans le fichier

	#get Otherinfo column number;
	echo -e "get Otherinfo column number"
	otherInfoNbCol=$(head -n 1 $multianno | awk '{ for(i;i<=NF;i++){ if ($i ~ /Otherinfo/) { print i } }}';)

	#Récupérer le header correspondant au nom de colonne du fichier vcf de $fileName de départ
	header="#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO"

	#Extraire toutes les colonnes avant OtherInfo et les coller dans un nouveau fichier 'multiannoOnly'
	echo -e "Extraire toutes les colonnes avant OtherInfo et les coller dans un nouveau fichier"
	cut -f1-$(($otherInfoNbCol-1)) $multianno > $fileName"Only.txt"

	#Extraire toutes les colonnes Otherinfo et les coller dans un nouveau fichier 'extract vcflike'
	cut -f$otherInfoNbCol- $multianno | sed -e 's/Otherinfo/'"$header"'/g' > $fileName"Extract.vcflike"
	
	#Librairie Perl pour vcf-query
	export PERL5LIB=/opt/vcftools_0.1.11/perl
		
	if [[ $type = "1K" ]]; then	
		echo -e "\t    a- Extract the wanted columns using vcf-query from vcf-tools (QUAL INFO/LDAF INFO/AC INFO/AN INFO/AF INFO/AMR_AF INFO/ASN_AF INFO/AFR_AF INFO/EUR_AF INFO/VT)"
		#~ INFO : 	LDAF (MLE Allele Frequency Accounting for LD)
		#~ 			AC (Alternate Allele Count)
		#~ 			AN (Total Allele Count)
		#~ 			AF (Global Allele Frequency based on AC/AN)
		#~ 			AMR_AF (Allele Frequency for samples from AMR based on AC/AN)
		#~ 			ASN_AF (Allele Frequency for samples from ASN based on AC/AN)
		#~ 			AFR_AF (Allele Frequency for samples from AFR based on AC/AN)
		#~ 			EUR_AF (Allele Frequency for samples from EUR based on AC/AN)
		#~ 			VT (Type of variant the line represents)
				
		#Tabuler les informations souhaitées : grâce à vcf-query
		awk 'BEGIN {OFS="\t"} BEGIN { print "QUAL", "LDAF", "AC", "AN", "AF", "AMR_AF", "ASN_AF", "AFR_AF", "EUR_AF", "VT"}' > $fileName"_extractedOtherinfo.txt"	
		echo "	    #CMD: vcf-query $fileName"Extract.vcflike" -f '%QUAL\t%INFO/LDAF\t%INFO/AC\t%INFO/AN\t%INFO/AF\t%INFO/AMR_AF\t%INFO/ASN_AF\t%INFO/AFR_AF\t%INFO/EUR_AF\t%INFO/VT\n'"
		vcf-query $fileName"Extract.vcflike" -f '%QUAL\t%INFO/LDAF\t%INFO/AC\t%INFO/AN\t%INFO/AF\t%INFO/AMR_AF\t%INFO/ASN_AF\t%INFO/AFR_AF\t%INFO/EUR_AF\t%INFO/VT\n' >> $fileName"_extractedOtherinfo.txt"

	elif [[ $type = "ESP" ]]; then
		echo -e "\t    a- Extract the wanted columns using vcf-query from vcf-tools (INFO/EA_AC INFO/AA_AC INFO/TAC INFO/MAF INFO/GTS INFO/EA_GTC INFO/AA_GTC INFO/GTC INFO/DP INFO/AA)"
		#~ INFO : 	EA_AC (European American Allele Count in the order of AltAlleles,RefAllele. For INDELs, A1, A2, or An refers to the N-th alternate allele while R refers to the reference allele.)
		#~ 			AA_AC (African American Allele Count in the order of AltAlleles,RefAllele. For INDELs, A1, A2, or An refers to the N-th alternate allele while R refers to the reference allele.)
		#~ 			TAC (Total Allele Count in the order of AltAlleles,RefAllele For INDELs, A1, A2, or An refers to the N-th alternate allele while R refers to the reference allele.)
		#~ 			MAF (Minor Allele Frequency in percent in the order of EA,AA,All)
		#~ 			GTS (Observed Genotypes. For INDELs, A1, A2, or An refers to the N-th alternate allele while R refers to the reference allele.)
		#~ 			EA_GTC (European American Genotype Counts in the order of listed GTS)
		#~ 			AA_GTC (African American Genotype Counts in the order of listed GTS)
		#~ 			GTC (Total Genotype Counts in the order of listed GTS)
		#~ 			DP (Average Sample Read Depth)
		#~ 			AA (chimpAllele)
		
		#Tabuler les informations souhaitées : grâce à vcf-query
		awk 'BEGIN {OFS="\t"} BEGIN { print "EA_AC", "AA_AC", "TAC", "MAF", "GTS", "EA_GTC", "AA_GTC", "GTC", "DP", "AA"}' > $fileName"_extractedOtherinfo.txt"
		echo "	    #CMD: vcf-query $fileName"Extract.vcflike" -f '%INFO/EA_AC\t%INFO/AA_AC\t%INFO/TAC\t%INFO/MAF\t%INFO/GTS\t%INFO/EA_GTC\t%INFO/AA_GTC\t%INFO/GTC\t%INFO/DP\t%INFO/AA\n'"
		vcf-query $fileName"Extract.vcflike" -f '%INFO/EA_AC\t%INFO/AA_AC\t%INFO/TAC\t%INFO/MAF\t%INFO/GTS\t%INFO/EA_GTC\t%INFO/AA_GTC\t%INFO/GTC\t%INFO/DP\t%INFO/AA\n' >> $fileName"_extractedOtherinfo.txt"

	elif [[ $type = "dbSNP" ]]; then
		echo -e "\t    a- Extract the wanted columns using vcf-query from vcf-tools (ID INFO/RSPOS INFO/dbSNPBuildID INFO/SAO INFO/SSR INFO/VC INFO/S3D INFO/CFL INFO/ASP INFO/NOC INFO/COMMON INFO/CLNHGVS INFO/CLNALLE INFO/CLNSRC INFO/CLNORIGIN INFO/CLNSRCID INFO/CLNSIG INFO/CLNDSDB INFO/CLNDSDBID INFO/CLNDBN INFO/CLNACC)"
		#~ INFO :	ID (rs identifier)
		#~ 			RSPOS (Chr position reported in dbSNP)
		#~ 			dbSNPBuildID (First dbSNP Build for RS)
		#~ 			SAO (Variant Allele Origin: 0 - unspecified, 1 - Germline, 2 - Somatic, 3 - Both)
		#~ 			SSR (Variant Suspect Reason Codes (may be more than one value added together) 0 - unspecified, 1 - Paralog, 2 - byEST, 4 - oldAlign, 8 - Para_EST, 16 - 1kg_failed, 1024 - other)
		#~ 			VC (Variation Class)
		#~ 			S3D (Has 3D structure - SNP3D table)
		#~ 			CFL (Has Assembly conflict. This is for weight 1 and 2 variant that maps to different chromosomes on different assemblies.)
		#~ 			ASP (Is Assembly specific. This is set if the variant only maps to one assembly)
		#~ 			NOC (Contig allele not present in variant allele list. The reference sequence allele at the mapped position is not present in the variant allele list, adjusted for orientation.)
		#~ 			COMMON (RS is a common SNP.  A common SNP is one that has at least one 1000Genomes population with a minor allele of frequency >= 1% and for which 2 or more founders contribute to that minor allele frequency.)
		#~ 			CLNHGVS (Variant names from HGVS.    The order of these variants corresponds to the order of the info in the other clinical  INFO tags.)
		#~ 			CLNALLE (Variant alleles from REF or ALT columns.  0 is REF, 1 is the first ALT allele, etc.  This is used to match alleles with other corresponding clinical (CLN) INFO tags.  A value of -1 indicates that no allele was found to match a corresponding HGVS allele name.)
		#~ 			CLNSRC (Variant Clinical Chanels)
		#~ 			CLNORIGIN (Allele Origin. One or more of the following values may be added: 0 - unknown; 1 - germline; 2 - somatic; 4 - inherited; 8 - paternal; 16 - maternal; 32 - de-novo; 64 - biparental; 128 - uniparental; 256 - not-tested; 512 - tested-inconclusive; 1073741824 - other)
		#~ 			CLNSRCID (Variant Clinical Channel IDs)
		#~ 			CLNSIG (Variant Clinical Significance, 0 - unknown, 1 - untested, 2 - non-pathogenic, 3 - probable-non-pathogenic, 4 - probable-pathogenic, 5 - pathogenic, 6 - drug-response, 7 - histocompatibility, 255 - other)
		#~ 			CLNDSDB (Variant disease database name)
		#~ 			CLNDSDBID (Variant disease database ID)
		#~ 			CLNDBN (Variant disease name)
		#~ 			CLNACC (Variant Accession and Versions)

		#Tabuler les informations souhaitées : grâce à vcf-query
		awk 'BEGIN {OFS="\t"} BEGIN { print "ID", "RSPOS", "dbSNPBuildID", "SAO", "SSR", "VC", "S3D", "CFL", "ASP", "NOC", "COMMON", "CLNHGVS", "CLNALLE", "CLNSRC", "CLNORIGIN", "CLNSRCID", "CLNSIG", "CLNDSDB", "CLNDSDBID", "CLNDBN", "CLNACC"}' > $fileName"_extractedOtherinfo.txt"
		echo "	    #CMD: vcf-query $fileName"Extract.vcflike" -f '%ID\t%INFO/RSPOS\t%INFO/dbSNPBuildID\t%INFO/SAO\t%INFO/SSR\t%INFO/VC\t%INFO/S3D\t%INFO/CFL\t%INFO/ASP\t%INFO/NOC\t%INFO/COMMON\t%INFO/CLNHGVS\t%INFO/CLNALLE\t%INFO/CLNSRC\t%INFO/CLNORIGIN\t%INFO/CLNSRCID\t%INFO/CLNSIG\t%INFO/CLNDSDB\t%INFO/CLNDSDBID\t%INFO/CLNDBN\t%INFO/CLNACC\n'"
		vcf-query $fileName"Extract.vcflike" -f '%ID\t%INFO/RSPOS\t%INFO/dbSNPBuildID\t%INFO/SAO\t%INFO/SSR\t%INFO/VC\t%INFO/S3D\t%INFO/CFL\t%INFO/ASP\t%INFO/NOC\t%INFO/COMMON\t%INFO/CLNHGVS\t%INFO/CLNALLE\t%INFO/CLNSRC\t%INFO/CLNORIGIN\t%INFO/CLNSRCID\t%INFO/CLNSIG\t%INFO/CLNDSDB\t%INFO/CLNDSDBID\t%INFO/CLNDBN\t%INFO/CLNACC\n' >> $fileName"_extractedOtherinfo.txt"
					
	fi

	#Fusionner le multiannoOnly et le extractedOtherinfo
	echo -e "\t    b- Write the extracted colums as tab separated"
	paste $fileName"Only.txt" $fileName"_extractedOtherinfo.txt" > $fileName"_TabSep.txt"
	
	#Suppression fichiers devenus inutile
	rm $fileName"Only.txt"
	rm $fileName"Extract.vcflike"
	rm $fileName"_extractedOtherinfo.txt"
		
	echo -e "\t 2- Column names change"
	#Sed Remplacer nom de colonnes
	sed -e s/"Chr"/"chrom"/g -e s/"Start"/"gPosStart"/g -e s/"End"/"gPosEnd"/g -e s/"Ref"/"ref"/g -e s/"Alt"/"alt"/g $fileName"_TabSep.txt" > $fileName".EVAnnot"
	
	#Suppression fichiers devenus inutile
	rm $fileName"_TabSep.txt"
		
	echo -e "\t #DONE - #Output $fileName.EVAnnot"
done

echo -e "\t TIME: END PARSING ".`date`



