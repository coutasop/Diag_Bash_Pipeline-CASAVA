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
    echo -e "\nUSAGE: run_Casava2vcf.sh -i <directory> -v <directory> -c <directory>"
    echo "		 -i <input Run Folder>"
    echo "		 -v <Variants Folder name>"
    echo "		 -c <Path to casava2vcf>"
    echo "\nEXAMPLE: ./run_Casava2vcf.sh -i /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX -v VariantsDiag -c /opt/alamut-ht-1.1.10"
    echo "\nREQUIREMENT: the casava2vcf script must be installed\n"
}

# get the arguments of the command line
if [ $# -lt 6 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-i | --input )         shift
					if [ "$1" != "" ]; then
						#Run folderPath path
						runFolder=$1
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
if [ -d $runFolder/$VariantsFolder/VCF ]; then
 echo -e "\n\tOUTPUT FOLDER: $runFolder/$VariantsFolder/VCF (folder already exist)" 
else
 mkdir -p $runFolder/$VariantsFolder/VCF 
 echo -e "\n\tOUTPUT FOLDER : $runFolder/$VariantsFolder/VCF (folder created)"
fi

chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT)

#Pour chaque Lane
for l in `ls $runFolder/$VariantsFolder | grep Project_`
do
	echo -e "\t----------------------------------------"
	lane=$(echo $l | awk -F"_" '{print $NF}');
	echo -e "\t$lane";
	#Pour chaque Individu
	for i in `ls $runFolder/$VariantsFolder/$l | grep Sample_`
	do
		echo -e "\t\t----------------------------------------"	
		echo -e "\t\t$i"
		#extrait le dernier champs du nom de fichier (en prenant '_' comme séparateur)
		#il s'agit du numero d'individu
		ind=$(echo $i | awk -F"_" '{print $NF}')
		echo -e "\t\t\t----------------------------------------"
		echo -e "\t\t\tIndividual "$ind

		#stocker le nom du dossier Parsed_date
		parsed=$(ls $runFolder/$VariantsFolder/$l/$i | grep Parsed)

		#file Conversion
		#ATTENTION BUG casava2vcf ne prend en compte qu'un argument sur 2 (??) La commande suivante donne donc 2 fois les mêmes fichiers
		$casava2vcfPath/casava2vcf -keepAllSNPs $runFolder/$VariantsFolder/$l/$i/$parsed/1/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/1/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/2/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/2/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/3/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/3/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/4/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/4/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/5/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/5/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/6/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/6/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/7/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/7/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/8/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/8/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/9/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/9/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/10/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/10/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/11/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/11/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/12/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/12/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/13/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/13/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/14/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/14/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/15/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/15/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/16/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/16/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/17/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/17/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/18/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/18/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/19/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/19/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/20/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/20/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/21/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/21/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/22/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/22/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/X/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/X/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/Y/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/Y/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/MT/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/MT/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/1/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/1/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/2/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/2/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/3/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/3/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/4/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/4/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/5/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/5/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/6/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/6/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/7/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/7/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/8/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/8/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/9/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/9/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/10/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/10/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/11/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/11/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/12/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/12/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/13/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/13/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/14/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/14/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/15/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/15/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/16/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/16/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/17/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/17/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/18/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/18/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/19/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/19/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/20/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/20/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/21/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/21/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/22/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/22/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/X/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/X/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/Y/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/Y/snps.txt $runFolder/$VariantsFolder/$l/$i/$parsed/MT/indels.txt $runFolder/$VariantsFolder/$l/$i/$parsed/MT/snps.txt > $runFolder"/$VariantsFolder/VCF/"$ind"_"$lane"_"casava2vcf.vcf
		
		echo -e "\t#DONE - #Output $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf'"		
		
		#Suprimme les headers en trop (le header correspondant à chaque chr est conservé, on ne veux garder que le premier)
		#1 get last line of the real Header
		lastLineHead=$(cat $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf | grep -n -m 1 "#CHROM" | awk -F":" '{print $1}')
		#2 write the header in a file
		head -n +$lastLineHead $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf > $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.header
		#Replace the "__SAMPLE__" header column with the real sample name
		sed -e s/"__SAMPLE__"/$ind/g $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.header > $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.headerSed
		
		
		#~ #3 select all the data (all lines but those which begin by a #)
		grep -v "#" $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf > $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.data
		#~ #4 put the real header and the data in the vcf
		cat $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.headerSed > $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf
		cat $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.data >> $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf
		#5 remove the temporary files
		rm $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.header
		rm $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.headerSed
		rm $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf.vcf.data
		#~ rm $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf-snp.vcf 
		#~ rm $runFolder/$VariantsFolder/VCF/"$ind"_"$lane"_casava2vcf-indel.vcf
	done
done
echo "--------------------------------------------------------------------------------------------------------------"
echo -e "\tTIME: END CASAVA2VCF CONVERSION".`date`
