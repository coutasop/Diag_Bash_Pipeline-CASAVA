#!/bin/bash
#
# Sophie COUTANT
# 11/09/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Ce script permet l'automatisation de la transformation des fichier snp.txt/indels.txt d'1 Run CASAVA en 1 fichier VCF                                        #
#                                                                                                                                                            #
# 1- loop for all Line, all Sample, all Chr													                                                                 #
# 2- Out put in Variant -> VCF 																																 #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

# usage
function usage
{
	echo -e "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo -e "# Ce script permet l'automatisation de la transformation des fichier snp.txt/indels.txt d'1 Run CASVA en 1 fichier VCF                                       #"
	echo -e "# 1- loop for all Line, all Sample, all Chr                                                                                                                  #"
	echo -e "# 2- Out put in Variant -> VCF                                                                                                                               #"
	echo -e "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
    echo -e "\nUSAGE: run_Casava2vcf.sh -v <directory> -o <directory> -c <directory>"
    echo "		 -v <Variants Folder name>"
    echo "		 -o <output Folder>"
    echo "		 -c <Path to casava2vcf>"
    echo "\nEXAMPLE: ./run_Casava2vcf.sh -o VCF -v VariantsDiag -c /opt/alamut-ht-1.1.10"
    echo "\nREQUIREMENT: the casava2vcf script must be installed\n"
}

# get the arguments of the command line
if [ $# -lt 6 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-o | --output )         shift
					if [ "$1" != "" ]; then
						#Run folderPath path
						out=$1
					else
						usage
						exit
					fi
		                        ;;
		-v | --variants )         shift
					if [ "$1" != "" ]; then
						#Variant folder name
						VariantsFolder=$1
					else
						usage
						exit
					fi
		                        ;;		                        
		-c | --casva2vcf )         shift
					if [ "$1" != "" ]; then
						#casava2vcf path
						casava2vcfPath=$1
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

echo -e "\tTIME: BEGIN CASAVA2VCF CONVERSION".`date`

#Test if the output directory exists, if no, create it
if [ -d $out ]; then
 echo -e "\n\tOUTPUT FOLDER: $out (folder already exist)" 
else
 mkdir -p $out 
 echo -e "\n\tOUTPUT FOLDER : $out (folder created)"
fi

chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT)


echo -e "\t\t----------------------------------------"	
echo -e "\t\t$VariantsFolder"
#extrait le dernier champs du nom de fichier (en prenant '_' comme séparateur)
#il s'agit du numero d'individu
ind=$(echo $VariantsFolder)
echo -e "\t\t\t----------------------------------------"
echo -e "\t\t\tIndividual "$ind

#stocker le nom du dossier Parsed_date
parsed=$(ls $VariantsFolder | grep Parsed)
echo -e "\t\t\tParsed "$parsed

#file Conversion
#ATTENTION BUG casava2vcf ne prend en compte qu'un argument sur 2 (??) La commande suivante donne donc 2 fois les mêmes fichiers
$casava2vcfPath/casava2vcf -keepAllSNPs $VariantsFolder/$parsed/1/snps.txt $VariantsFolder/$parsed/1/indels.txt $VariantsFolder/$parsed/2/snps.txt $VariantsFolder/$parsed/2/indels.txt $VariantsFolder/$parsed/3/snps.txt $VariantsFolder/$parsed/3/indels.txt $VariantsFolder/$parsed/4/snps.txt $VariantsFolder/$parsed/4/indels.txt $VariantsFolder/$parsed/5/snps.txt $VariantsFolder/$parsed/5/indels.txt $VariantsFolder/$parsed/6/snps.txt $VariantsFolder/$parsed/6/indels.txt $VariantsFolder/$parsed/7/snps.txt $VariantsFolder/$parsed/7/indels.txt $VariantsFolder/$parsed/8/snps.txt $VariantsFolder/$parsed/8/indels.txt $VariantsFolder/$parsed/9/snps.txt $VariantsFolder/$parsed/9/indels.txt $VariantsFolder/$parsed/10/snps.txt $VariantsFolder/$parsed/10/indels.txt $VariantsFolder/$parsed/11/snps.txt $VariantsFolder/$parsed/11/indels.txt $VariantsFolder/$parsed/12/snps.txt $VariantsFolder/$parsed/12/indels.txt $VariantsFolder/$parsed/13/snps.txt $VariantsFolder/$parsed/13/indels.txt $VariantsFolder/$parsed/14/snps.txt $VariantsFolder/$parsed/14/indels.txt $VariantsFolder/$parsed/15/snps.txt $VariantsFolder/$parsed/15/indels.txt $VariantsFolder/$parsed/16/snps.txt $VariantsFolder/$parsed/16/indels.txt $VariantsFolder/$parsed/17/snps.txt $VariantsFolder/$parsed/17/indels.txt $VariantsFolder/$parsed/18/snps.txt $VariantsFolder/$parsed/18/indels.txt $VariantsFolder/$parsed/19/snps.txt $VariantsFolder/$parsed/19/indels.txt $VariantsFolder/$parsed/20/snps.txt $VariantsFolder/$parsed/20/indels.txt $VariantsFolder/$parsed/21/snps.txt $VariantsFolder/$parsed/21/indels.txt $VariantsFolder/$parsed/22/snps.txt $VariantsFolder/$parsed/22/indels.txt $VariantsFolder/$parsed/X/snps.txt $VariantsFolder/$parsed/X/indels.txt $VariantsFolder/$parsed/Y/snps.txt $VariantsFolder/$parsed/Y/indels.txt $VariantsFolder/$parsed/MT/snps.txt $VariantsFolder/$parsed/MT/indels.txt $VariantsFolder/$parsed/1/indels.txt $VariantsFolder/$parsed/1/snps.txt $VariantsFolder/$parsed/2/indels.txt $VariantsFolder/$parsed/2/snps.txt $VariantsFolder/$parsed/3/indels.txt $VariantsFolder/$parsed/3/snps.txt $VariantsFolder/$parsed/4/indels.txt $VariantsFolder/$parsed/4/snps.txt $VariantsFolder/$parsed/5/indels.txt $VariantsFolder/$parsed/5/snps.txt $VariantsFolder/$parsed/6/indels.txt $VariantsFolder/$parsed/6/snps.txt $VariantsFolder/$parsed/7/indels.txt $VariantsFolder/$parsed/7/snps.txt $VariantsFolder/$parsed/8/indels.txt $VariantsFolder/$parsed/8/snps.txt $VariantsFolder/$parsed/9/indels.txt $VariantsFolder/$parsed/9/snps.txt $VariantsFolder/$parsed/10/indels.txt $VariantsFolder/$parsed/10/snps.txt $VariantsFolder/$parsed/11/indels.txt $VariantsFolder/$parsed/11/snps.txt $VariantsFolder/$parsed/12/indels.txt $VariantsFolder/$parsed/12/snps.txt $VariantsFolder/$parsed/13/indels.txt $VariantsFolder/$parsed/13/snps.txt $VariantsFolder/$parsed/14/indels.txt $VariantsFolder/$parsed/14/snps.txt $VariantsFolder/$parsed/15/indels.txt $VariantsFolder/$parsed/15/snps.txt $VariantsFolder/$parsed/16/indels.txt $VariantsFolder/$parsed/16/snps.txt $VariantsFolder/$parsed/17/indels.txt $VariantsFolder/$parsed/17/snps.txt $VariantsFolder/$parsed/18/indels.txt $VariantsFolder/$parsed/18/snps.txt $VariantsFolder/$parsed/19/indels.txt $VariantsFolder/$parsed/19/snps.txt $VariantsFolder/$parsed/20/indels.txt $VariantsFolder/$parsed/20/snps.txt $VariantsFolder/$parsed/21/indels.txt $VariantsFolder/$parsed/21/snps.txt $VariantsFolder/$parsed/22/indels.txt $VariantsFolder/$parsed/22/snps.txt $VariantsFolder/$parsed/X/indels.txt $VariantsFolder/$parsed/X/snps.txt $VariantsFolder/$parsed/Y/indels.txt $VariantsFolder/$parsed/Y/snps.txt $VariantsFolder/$parsed/MT/indels.txt $VariantsFolder/$parsed/MT/snps.txt > $ind"_casava2vcf.vcf"

echo -e "\t#DONE - #Output "$ind"_casava2vcf.vcf"		

#Suprimme les headers en trop (le header correspondant à chaque chr est conservé, on ne veux garder que le premier)
#1 get last line of the real Header
lastLineHead=$(cat "$ind"_casava2vcf.vcf | grep -n -m 1 "#CHROM" | awk -F":" '{print $1}')
#2 write the header in a file
head -n +$lastLineHead "$ind"_casava2vcf.vcf > "$ind"_casava2vcf.vcf.header
#Replace the "__SAMPLE__" header column with the real sample name
sed -e s/"__SAMPLE__"/$ind/g "$ind"_casava2vcf.vcf.header > "$ind"_casava2vcf.vcf.headerSed


#~ #3 select all the data (all lines but those which begin by a #)
grep -v "#" "$ind"_casava2vcf.vcf > "$ind"_casava2vcf.vcf.data
#~ #4 put the real header and the data in the vcf
cat "$ind"_casava2vcf.vcf.headerSed > "$ind"_casava2vcf.vcf
cat "$ind"_casava2vcf.vcf.data >> "$ind"_casava2vcf.vcf
#5 remove the temporary files
rm "$ind"_casava2vcf.vcf.header
rm "$ind"_casava2vcf.vcf.headerSed
rm "$ind"_casava2vcf.vcf.data
#~ rm "$ind"_casava2vcf-snp.vcf 
#~ rm "$ind"_casava2vcf-indel.vcf

echo "--------------------------------------------------------------------------------------------------------------"
echo -e "\tTIME: END CASAVA2VCF CONVERSION".`date`
