#!/bin/bash
#
# Sophie COUTANT
# 02/10/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# This script allows the automation of quality analysis using Samtools and various home made scripts                                                         #
# 1- call the script run_depthDiag.sh (see script for more details)                                                                                          #
# 2- call the script RapportQual.sh (Extract the diagnostic ROI from depth.bed, see script for more details)                                                 #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#


# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# This script allows the automation of quality analysis using Samtools and various home made scripts                                                         #"
	echo "# 1- call the script run_depthDiag.sh (see script for more details)                                                                                          #"
	echo "# 2- call the script RapportQual.sh (Extract the diagnostic ROI from depth.bed, see script for more details)                                                 #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: run_qualDiag.sh -runFold <directory> -agBed <file> -bed <file> -nbGa <number> -nbDiag <number> -opGa <letters> -a <alamutHTdir> -o <variant Folder>" 
	echo "	-runFold <input Run Folder>"
	echo "	-agBed <Official Agilent bed file (Target)>"
	echo "	-bed <Diagnostic ROI bed file>"
	echo "	-nbGa <GaIIx Run number>"
	echo "	-nbDiag <Diagnostic Run number>"
	echo "	-opGa <input Run Folder>"
	echo "	-a <alamutHTdir>"
	echo "	-o <variant Folder>"
	echo "EXAMPLE: ./run_qualDiag.sh -runFold /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX -agBed /storage/IN/Reference/Capture/MMR/036540_D_BED_20110915-DiagK_colique-U614_TARGET.bed -bed /storage/IN/Reference/Capture/MMR/DiagCapture-11genes_20130730.bed -nbGa 3 -nbDiag 2 -opGa IT -a /opt/alamutHT -o /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX/Variants"
	echo -e "\nREQUIREMENT: Samtools must be instaled and in your PATH\n"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 12 ]; then
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
		-agBed | --agilentBed )         shift
					if [ "$1" != "" ]; then
						#agilent Bed Path
						agBedFile=$1
					else
						usage
						exit
					fi
		                        ;;
		-bed | --bedFile )         shift
					if [ "$1" != "" ]; then
						#bed File Path
						bedFile=$1
					else
						usage
						exit
					fi
		                        ;;
		-nbGa | --GaIIxRunNumber )         shift
					if [ "$1" != "" ]; then
						#GaIIx Run Number
						nbGa=$1
					else
						usage
						exit
					fi
		                        ;;
		-nbDiag | --DiagRunNumber )         shift
					if [ "$1" != "" ]; then
						#Diagnostic Run Number
						nbDiag=$1
					else
						usage
						exit
					fi
		                        ;;		
		-opGa | --operatorGa )         shift
					if [ "$1" != "" ]; then
						#GaIIx operator
						opGa=$1
					else
						usage
						exit
					fi
		                        ;;
		-o | --outputdir )         shift
					if [ "$1" != "" ]; then
						#variantsdir path
						variantsdir=$1
					else
						usage
						exit
					fi
		                        ;;	
	    esac
	    shift
	done
fi


echo -e "\tTIME: BEGIN RUN DIAG QUALITY".`date`
#Get the path of all the scripts that will be launched (autoAnnot path)
scriptPath=$(dirname $0)

VariantsFolder=$(echo $variantsdir | awk 'BEGIN {FS="/"} {print $NF}')

#Executing the run_depthDiag.sh script
echo -e "\n\t#---------------------------------------------------------#"
echo -e "\tI- RUNNING run_depthDiag.sh"
echo -e "\t#CMD: $scriptPath/run_depthDiag.sh -i $runFolder -bed $agBedFile --v $VariantsFolder"
$scriptPath/run_depthDiag.sh -i $runFolder -bed $agBedFile -v $VariantsFolder

#Executing the run_prepareRapportQual.sh script
echo -e "\n\t#---------------------------------------------------------#"
echo -e "\tII- RUNNING run_prepareRapportQual.sh"
echo -e "\t#CMD: $scriptPath/run_prepareRapportQual.sh -i $runFolder -bed $bedFile  -v $VariantsFolder"
$scriptPath/run_prepareRapportQual.sh -i $runFolder -bed $bedFile  -v $VariantsFolder

#~ #Executing the Rapport_QualPatient.jar script
#~ echo -e "\n\t#---------------------------------------------------------#"
#~ echo -e "\tIII- RUNNING java Rapport_QualPatient reports"
#~ echo -e "\t#CMD: java -jar $scriptPath/Rapport_QualPatient.jar $runFolder/ $nbGa $nbDiag $opGa $bedFile"
#~ java -jar $scriptPath/Rapport_QualPatient.jar $runFolder/ $nbGa $nbDiag $opGa $bedFile
#~ 
#~ #Executing the Rapport_Qual.jar script
#~ echo -e "\n\t#---------------------------------------------------------#"
#~ echo -e "\tVI- RUNNING java Rapport_Qual report"
#~ echo -e "\t#CMD: java -jar $scriptPath/Rapport_Qual.jar $runFolder/ $nbGa $nbDiag $opGa $bedFile"
#~ java -jar $scriptPath/Rapport_Qual.jar $runFolder/ $nbGa $nbDiag $opGa $bedFile

#Executing the cpBam.sh script
echo -e "\n\t#---------------------------------------------------------#"
echo -e "\tVII- RUNNING cpBam.sh"
echo -e "\t#CMD: $scriptPath/cpBam.sh -runFold $runFolder -v $VariantsFolder -o bamDiag"
$scriptPath/cpBam.sh -runFold $runFolder -v $VariantsFolder -o bamDiag

echo -e "\n\t#---------------------------------------------------------#"
echo -e "\t#ALLDONE: run_qualDiag.sh"
echo -e "\t#---------------------------------------------------------#"
echo -e "\tTIME: END RUN DIAG QUALITY".`date`	
