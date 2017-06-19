#!/bin/bash
#
# Sophie
# LAST UPDATE : 31/06/2016
#

# usage
function usage
{
	echo "#----------------------------------------------------------------------------------------------------------#"
	echo "#This script must generate a BAPT Switch2CASAVA settings file                                              #"
	echo "#----------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: switch2casava-settings-creator.sh -sSheet <file> -runFold <dir> -project <text>" 
	echo "	-sSheet <path to sampleSheet file>"
	echo "	-runFold <path to run folder>"
	echo "	-project <project>"	
	echo "EXAMPLE: ./switch2casava-settings-creator.sh -sSheet /storage/crihan-msa/RunsPlateforme/NextSeq/SampleSheet_Config/160504/SampleSheet.csv -runFold /storage/crihan-msa/RunsPlateforme/NextSeq/160504_NB501076_0013_AH7LF5AFXX -project RunColonNS5"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 6 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-sSheet | --sSheet )    	shift
					if [ "$1" != "" ]; then
						sSheet=$1
					else
						usage
						exit
					fi
		                        ;;
		-runFold | --runFold )    	shift
					if [ "$1" != "" ]; then
						runFold=$1
					else
						usage
						exit
					fi
		                        ;;    
		-project | --project )    	shift
					if [ "$1" != "" ]; then
						proj=$1
					else
						usage
						exit
					fi
		                        ;;  		                         
	    esac
	    shift
	done
fi

echo -e "\nTIME: BEGIN SWITCH2CASAVA SETTINGS CREATOR ".`date`

#Get column number of the Sample_Project column
sampProjNbCol=$(grep "Sample_Project" $sSheet | awk -F, '{ for(i;i<=NF;i++){ if ($i ~ /Sample_Project/) { print i } }}';)
projFileNbCol=$(grep "Description" $sSheet | awk -F, '{ for(i;i<=NF;i++){ if ($i ~ /Description/) { print i } }}';)
OpSeqNbCol=$(grep "Description" $sSheet | awk -F, '{ for(i;i<=NF;i++){ if ($i ~ /OpSeq/) { print i } }}';)

while read ligne
do
	sampProj=$(echo $ligne | cut -d "," -f $sampProjNbCol)
	projFile=$(echo $ligne | cut -d "," -f $projFileNbCol)
	OpSeq=$(echo $ligne | cut -d "," -f $OpSeqNbCol)
	if [ "$projFile" != "$proj" ]
	then
		#tant que le projet de la samplesheet n'est pas le même que celui défini dans le setting on continue de parcourir le fichier
		continue
	else
		#des que les deux projet match on stop et on conserve la valeur de $sampProj pour remplir les settings BAPT
		break
	fi
done <  $sSheet

echo -e "\n\tGetting information from sampleSheet..."
echo -e "\t\tsampleGroup: "$sampProj
echo -e "\t\tproject: "$projFile
echo -e "\t\tOpSeq: "$OpSeq

#geneRate Seting file
echo -e "\n\tGenerating BAPT switch2CASAVA settings..."

touch $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "<BAPT>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo " <params name=\"General\">" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <resultDirectory>"$runFold"</resultDirectory>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <analysisDirectory>"$runFold"</analysisDirectory>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <sample-sheet>"$sSheet"</sample-sheet>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <email></email>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <core>8</core>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo " </params>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo " <tool name=\"switchToCASAVA\">" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo " <inout>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <output-dir>"$runFold"/Unaligned"$proj"</output-dir>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <runfolder-dir>"$runFold"</runfolder-dir>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <fastq-dir>"$runFold"/Unaligned"$proj"_dem/"$sampProj"</fastq-dir>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo " </inout>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  <BAPTparams>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "   <SampleRef></SampleRef>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "   <Operator>"$OpSeq"</Operator>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "   <Control></Control>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "   <Description></Description>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "   <Recipe></Recipe>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "   <SampleProject>"$proj"</SampleProject>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "  </BAPTparams>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo " </tool>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"
echo "</BAPT>" >> $runFold"/BAPT_Config-"$proj"_SwitchToCASAVA.xml"

echo -e "\tDone"
echo -e "\n\tGenerated settings : BAPT_Config-"$proj"_SwitchToCASAVA.xml"

echo -e "\nTIME: END SWITCH2CASAVA SETTINGS CREATOR ".`date`

