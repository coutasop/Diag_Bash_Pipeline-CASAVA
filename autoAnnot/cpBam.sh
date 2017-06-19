#!/bin/bash
#
# Sophie COUTANT
# 10/10/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# This script extract the bam files into the CASAVA Run folder and rename them with the patient code                                                         #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# This script extract the bam files into the CASAVA Run folder and rename them with the patient code                                                         #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: cpBam.sh -runFold <directory> -v <directory> -o <output>" 
	echo "	-runFold <input Run Folder>"
	echo "	-v <Variants Folder name>"
	echo "	-o <output Folder name>"
	echo "EXAMPLE: ./cpBam.sh -runFold /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX -v VariantsDiag -o bamDiag"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 6 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-runFold | --runFolder )    	shift
					if [ "$1" != "" ]; then
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
		-o | --output )         shift
			if [ "$1" != "" ]; then
				#output folder name
				output=$1
			else
				usage
				exit
			fi
						;;						
		esac
	    shift
	done
fi		                        

echo -e "\tTIME: BEGIN CP BAM".`date`

#Test if the output directory exists, if no, create it
if [ -d $runFolder/$output ]; then
 echo -e "\n\tOUTPUT FOLDER: $runFolder/$output (folder already exists)" 
else
 mkdir -p $runFolder/$output
 echo -e "\n\tOUTPUT FOLDER : $runFolder/$output (folder created)"
fi

#Pour chaque Lane
for i in `ls $runFolder/$VariantsFolder | grep Project_`
do
	echo -e "\n\tLane $i";
	#Pour chaque Individu
	for j in `ls $runFolder/$VariantsFolder/$i | grep Sample_`
	do
		#extrait le dernier champs du nom de fichier (en prenant '_' comme séparateur)
		#il s'agit du numero d'individu
		ind=$(echo $j | awk -F"_" '{print $NF}')
		echo -e "\t\t----------------------------------------"
		
		#Copier les bam avec leur nom de patients dans un dossier bam (s'ils n'y sont pas déjà)
		if [ -f $runFolder/$output/$ind"_sorted.bam" ]; then
			echo -e "\t\tno copy: "$ind"_sorted.bam (already exists)"
		else
			echo -e "\t\tcopy: "$ind"_sorted.bam"
			cp $runFolder/$VariantsFolder/$i/$j/genome/bam/sorted.bam $runFolder/$output/$ind"_sorted.bam"
			cp $runFolder/$VariantsFolder/$i/$j/genome/bam/sorted.bam.bai $runFolder/$output/$ind"_sorted.bam.bai"
		fi
	done
done
echo -e "\n\t#DONE: cpBam.sh"

echo -e "\tTIME: END CP BAM".`date`
