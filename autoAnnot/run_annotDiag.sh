#!/bin/bash
#
# Sophie COUTANT
# 02/10/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# This script allows the automation of variants annotation using the AlamutHT tool, and allows the parsing of the output to generate a standard input for xls#
# Reports:                                                                                                                                                   #
# 1- call the script run_alamutHT.sh (Annotation, see script for more details)                 				                                                 #
# 2- call the script run_extract.sh (Extract NM and diagnostic ROI, see script for more details)   		                                                 	 #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#


# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# This script allows the automation of variants annotation using the AlamutHT tool, and allows the parsing of the output to generate a standard input for xls#"
	echo "# Reports:                                                                                                                                                   #"
	echo "# 1- call the script run_alamutHT.sh (Annotation, see script for more details)                                                                               #"
	echo "# 2- call the script run_extract.sh (Extract NM and diagnostic ROI, see script for more details)                                                             #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: run_annotDiag.sh -runFold <directory> -glist <file> -nm <file> -bed <file> -nbGa <number> -nbDiag <number> -opGa <letters> -a <directory> -o <directory>" 
	echo "	-runFold <input Run Folder>"
	echo "	-glist <file containing the genelist to annotate>"
	echo "	-nm <file containing the nmList to extract>"
	echo "	-bed <bed file containing the region of interest>"
	echo "	-nbGa <GaIIx Run number>"
	echo "	-nbDiag <Diagnostic Run number>"
	echo "	-opGa <input Run Folder>"
	echo "	-a <alamutHT source directory>"
	echo "	-o <variant directory>"
	echo "EXAMPLE: ./run_annotDiag.sh -runFold /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX -glist /storage/IN/Reference/Capture/MMR/geneList.txt -nm /storage/IN/Reference/Capture/MMR/nmList.txt -bed /storage/IN/Reference/Capture/MMR/DiagCapture-11genes_20130506_extract.bed -nbGa 3 -nbDiag 2 -opGa IT -a /opt/alamut-ht-1.1.10 -o /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX/Variants"
	echo -e "\nREQUIREMENT: AlamutHT must be instaled. BedTool must be installed and in your PATH\n"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 16 ]; then
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
		-glist | --geneList )         shift
					if [ "$1" != "" ]; then
						#geneList Path
						geneList=$1
					else
						usage
						exit
					fi
		                        ;;
		-nm | --nmFile )         shift
					if [ "$1" != "" ]; then
						#nmFile Path
						nmFile=$1
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
		-a | --alamutHT )         shift
					if [ "$1" != "" ]; then
						#alamutHTPath path
						alamutHTPath=$1
					else
						usage
						exit
					fi
		                        ;;
		-o | --output )         shift
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


echo -e "\tTIME: BEGIN RUN DIAG ANNOTATION".`date`
#Get the path of all the scripts that will be launched (autoAnnot path)
scriptPath=$(dirname $0)
VariantsFolder=$(echo $variantsdir | awk 'BEGIN {FS="/"} {print $NF}')

#Executing the run_Casave2vcf.sh script
echo -e "\n\t#---------------------------------------------------------#"
echo -e "\tI- RUNNING casava2vcf"
echo -e "\t#CMD: $scriptPath/run_Casava2vcf.sh -i $runFolder -v $VariantsFolder -c $alamutHTPath"
$scriptPath/run_Casava2vcf.sh -i $runFolder -v $VariantsFolder -c $alamutHTPath

#Executing the run_alamutHT.sh script
echo -e "\n\t#---------------------------------------------------------#"
echo -e "\tII- RUNNING alamutHT"
echo -e "\t#CMD: $scriptPath/run_alamutHT.sh -i $runFolder/$VariantsFolder/VCF -o $runFolder/$VariantsFolder/alamutHT -glist $geneList -a $alamutHTPath"
$scriptPath/run_alamutHT.sh -i $runFolder/$VariantsFolder/VCF -o $runFolder/$VariantsFolder/alamutHT -glist $geneList -a $alamutHTPath

#Executing the run_extract.sh script
echo -e "\n\t#---------------------------------------------------------#"
echo -e "\tIII- RUNNING extract"
echo -e "\t#CMD: $scriptPath/run_extract.sh -i $runFolder/$VariantsFolder/alamutHT -o $runFolder/$VariantsFolder/Result_alamutHT/Fbrut -nm $nmFile -bed $bedFile -bt $bedtoolsdir"
$scriptPath/run_extract.sh -i $runFolder/$VariantsFolder/alamutHT -o $runFolder/$VariantsFolder/Result_alamutHT/Fbrut -nm $nmFile -bed $bedFile -bt $bedtoolsdir

#Test if the Report output directory exists, if no, create it
if [ -d $runFolder/$VariantsFolder/Result_alamutHT/Rapport/ ]; then
 echo -e "\n\tOUTPUT FOLDER: $runFolder/$VariantsFolder/Result_alamutHT/Rapport/ (folder already exist)" 
else
 mkdir -p $runFolder/$VariantsFolder/Result_alamutHT/Rapport/
 echo -e "\n\tOUTPUT FOLDER : $runFolder/$VariantsFolder/Result_alamutHT/Rapport/ (folder created)"
fi

#~ #Executing the Rapport_Variants.jar script
#~ echo -e "\n\t#---------------------------------------------------------#"
#~ echo -e "\tVI- RUNNING java variants reports"
#~ echo -e "\t#CMD: java -jar $scriptPath/Rapport_Variants.jar $runFolder/ $nbGa $nbDiag $opGa"
#~ java -jar $scriptPath/Rapport_Variants.jar $runFolder/ $nbGa $nbDiag $opGa

echo -e "\n\t#---------------------------------------------------------#"
echo -e "\t#ALLDONE: run_annotDiag.sh"
echo -e "\t#---------------------------------------------------------#"
echo -e "\tTIME: END RUN DIAG ANNOTATION".`date`	
