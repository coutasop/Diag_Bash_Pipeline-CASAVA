#!/bin/bash
#
# Sophie COUTANT
# 12/09/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Ce script permet l'automatisation du lancement d'AlamutHT sur un ensemble de fichiersVCF pour une liste de gènes donnée dans les regions d'interêts		 #
# 		définies par le fichier bed																															 #
#                                                                                                                                                            #
# 1- loop for all Sample																	                                                                 #
# 2- Output tabulated text file																																 #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

# usage
function usage
{
    echo -e "\nUSAGE: run_alamutHT.sh -i <directory> -o <directory> -glist <file> -a <directory> [optional -bed <file>]"
    echo "		 -i <input VCF Folder>"
    echo "		 -o <output Folder>"
    echo "		 -glist <file containing the genelist to annotate>"
    echo "		 -a <Path to alamutHT>"
    echo "		 [optional] -bed <bed file containing the region of interest>"
    echo "\nEXAMPLE: ./run_alamutHT.sh -i /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX/VariantsDiag/VCF -o /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX/VariantsDiag/AlamuHT -glist /storage/IN/Reference/Capture/MMR/geneList.txt -a /opt/alamut-ht-1.1.10"
    echo "\nREQUIREMENT: alamutHT must be installed\n"
}

# get the arguments of the command line
if [ $# -lt 8 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-i | --input )         shift
					if [ "$1" != "" ]; then
						#Run folderPath path
						inputFolder=$1
					else
						usage
						exit
					fi
		                        ;;
		-o | --output )         shift
					if [ "$1" != "" ]; then
						#Output folder Path
						outputFolder=$1
					else
						usage
						exit
					fi
		                        ;;
		-glist | --geneList )         shift
					if [ "$1" != "" ]; then
						#geneList Path
						geneList=$1
					else
						usage
						exit
					fi
		                        ;;
		-bed | --bedFile )         shift
					if [ "$1" != "" ]; then
						#bedFile Path
						bedFile=$1
					else
						usage
						exit
					fi
		                        ;;		                    
		-a | --alamutHT )         shift
					if [ "$1" != "" ]; then
						#alamutHTPath path
						alamutHTPath=$1
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

echo -e "\tTIME: BEGIN ALAMUTHT ANNOTATION".`date`

#Test if the output directory exists, if no, create it
if [ -d $outputFolder ]; then
 echo -e "\n\tOUTPUT FOLDER: $outputFolder (folder already exist)" 
else
 mkdir -p $outputFolder 
 echo -e "\n\tOUTPUT FOLDER : $outputFolder (folder created)"
fi

chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y)

#Pour chaque fichier vcf du folder
for f in `ls $inputFolder/*.vcf`
do
	echo -e "\t----------------------------------------"
	fich=$(basename $f) #nom du fichier sans path
	path=$(dirname $f) #nom du path, sans le fichier
	#~ fich=$(echo $f| awk -F"_" '{print $NF}');
	echo -e "\t$fich";

	#extrait le premier champ du nom de fichier (en prenant '_' comme séparateur)
	#il s'agit du numero d'individu
	ind=$(echo $fich | awk -F"_" '{print $1}')
	echo -e "\t\t----------------------------------------"
	echo -e "\t\tIndividual "$ind

	if [ 1$bedFile -eq 1 ]; then
		#No bedFile Command
		#~ echo "NO BEDFILE"
		echo -e "COMMAND: $alamutHTPath/alamut-ht --in $inputFolder/$fich --ann $outputFolder/$fich.ann --unann $outputFolder/$fich.unann --alltrans --glist $geneList --nonnsplice --nogenesplicer --ssIntronicRange 2 --outputVCFQuality --outputVCFInfo DP A_used C_used G_used T_used alt_reads indel_reads --outputVCFGenotypeData GT DP";
		$alamutHTPath/alamut-ht --in $inputFolder/$fich --ann $outputFolder/$fich.ann --unann $outputFolder/$fich.unann --alltrans --glist $geneList --nonnsplice --nogenesplicer --ssIntronicRange 2 --outputVCFQuality --outputVCFInfo Q_snp Q_max_gt DP A_used C_used G_used T_used alt_reads indel_reads --outputVCFGenotypeData GT DP --outputEmptyValuesAs .
	else
		#BedFile Command
		#~ echo "BEDFILE"
		echo -e "COMMAND: $alamutHTPath/alamut-ht --in $inputFolder/$fich --ann $outputFolder/$fich.ann --unann $outputFolder/$fich.unann --alltrans --glist $geneList --roilist $bedFile --nonnsplice --nogenesplicer --ssIntronicRange 2 --outputVCFQuality --outputVCFInfo DP A_used C_used G_used T_used alt_reads indel_reads --outputVCFGenotypeData GT DP";
		$alamutHTPath/alamut-ht --in $inputFolder/$fich --ann $outputFolder/$fich.ann --unann $outputFolder/$fich.unann --alltrans --glist $geneList --roilist $bedFile --nonnsplice --nogenesplicer --ssIntronicRange 2 --outputVCFQuality --outputVCFInfo Q_snp Q_max_gt DP A_used C_used G_used T_used alt_reads indel_reads --outputVCFGenotypeData GT DP --outputEmptyValuesAs .
	fi
	
	#Control if the .unann file is emty -> else WARNING
	unannSize=`wc -l $outputFolder/$fich.unann | awk '{print $1}'`
	if [ $unannSize -eq 0 ]; then
		echo -e "\t\t#DONE with Success - #Output $outputFolder/$fich.ann"			
	else
		echo -e "WARNING: Some variants are not annotated! $ind"
		echo -e "\t\t#DONE with WARNING - #Output $outputFolder/$fich.ann & $outputFolder/$fich.unann"			
	fi
	
done
echo "--------------------------------------------------------------------------------------------------------------"
echo -e "\tTIME: END ALAMUTHT ANNOTATION".`date`
