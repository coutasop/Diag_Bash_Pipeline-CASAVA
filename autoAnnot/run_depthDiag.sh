#!/bin/bash
#
# Sophie COUTANT
# 03/10/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Script permettant, pour un run CASAVA donné, de générer les fichier depth.bed                                                                              #
# 1- run samtools depth                                                                                                                                      #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# Script permettant, pour un run CASAVA donné, de générer les fichier depth.bed                                                                              #"
	echo "# 1- run samtools depth                                                                                                                                      #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
    echo -e "\nUSAGE: run_depthDiag.sh -i <directory> -bed <file> -v <folder>"
    echo "		 -i <input Folder>"
    echo "		 -bed <Agilent Target bed file>"
    echo "		 -v <variant Name>"
    echo -e "\nEXAMPLE: ./run_depthDiag.sh -i /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX -bed /storage/IN/Reference/Capture/MMR/036540_D_BED_20110915-DiagK_colique-U614_TARGET.bed -v variantsProject"
    echo -e "\nREQUIREMENT: Samtools must be installed and in your PATH\n"
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
		-bed | --bedFile )         shift
					if [ "$1" != "" ]; then
						#bedFile path
						bedFile=$1
					else
						usage
						exit
					fi
		                        ;;
		-v | --$variantDir )         shift
					if [ "$1" != "" ]; then
						#Run variantDir path
						variantDir=$1
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

echo -e "\tTIME: BEGIN RUN DEPTH".`date`
#Pour chaque Lane
for l in `ls $runFolder/$variantDir | grep Project_`
do
	echo -e "\t----------------------------------------"
	lane=$(echo $l | awk -F"_" '{print $NF}');
	echo -e "\t$lane";
	#Pour chaque Individu
	for i in `ls $runFolder/$variantDir/$l | grep Sample_`
	do
		echo -e "\t\t----------------------------------------"	
		echo -e "\t\t$i"
		
		#Test if the output directory exists, if no, create it
		if [ -d $runFolder/$variantDir/$l/$i/genome/depth ]; then
		 echo -e "\n\tOUTPUT FOLDER: $runFolder/$variantDir/$l/$i/genome/depth (folder already exist)" 
		else
		 mkdir -p $runFolder/$variantDir/$l/$i/genome/depth
		 echo -e "\n\tOUTPUT FOLDER : $runFolder/$variantDir/$l/$i/genome/depth (folder created)"
		fi
		
		#execute les calculs profondeur
		echo -e "COMMAND: samtools depth -d 10000000 -b $bedFile $runFolder/$variantDir/$l/$i/genome/bam/sorted.bam > $runFolder/$variantDir/$l/$i/genome/depth/depth.bed;";
		samtools depth -d 10000000 -b $bedFile $runFolder/$variantDir/$l/$i/genome/bam/sorted.bam > $runFolder/$variantDir/$l/$i/genome/depth/depth.bed;

		#~ chmod 777 $runFolder/$variantDir/$l/$i/genome/bam/sorted.bam > $runFolder/$variantDir/$l/$i/genome/depth/depth.bed;
	done
done
echo -e "\tTIME: END RUN DEPTH".`date`

