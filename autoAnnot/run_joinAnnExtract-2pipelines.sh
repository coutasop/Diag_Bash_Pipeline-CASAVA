#!/bin/bash
#
# Sophie COUTANT
# 06/06/2014
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Ce script permet l'automatisation du lancement de la fusion des annotations issus des 2 pipelines pour le diagnostique                                     #
#                                                                                                                                                            #
# 1- Add pipeline tag                                                                                                                                        #
# 2- Fusion des liste de variants issues des 2 pipeline                                                                                                      #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

# usage
function usage
{
    echo -e "\nUSAGE: run_joinAnnExtract-2pipelines.sh -inCAS <directory> -inGATK <directory> -o <directory>"
    echo "		 -inCAS <CASAVA ann-extract input Folder>"
    echo "		 -inGATK <GATK ann-extract input Folder>"
    echo "		 -o <output Folder>"
    echo -e "\nEXAMPLE: ./run_joinAnnExtract-2pipelines.sh -inCAS /storage/crihan-msa/runsPlateforme/GaIIx/111125_HWUSI-EAS1884_00002_FC64F86AAXX/VariantsDiag/Result_alamutHT/Fbrut -inGATK /storage/crihan-msa/runsPlateforme/GaIIx/111125_HWUSI-EAS1884_00002_FC64F86AAXX/BWA-GATK_Diag/ANN-EXTRACT -o /storage/crihan-msa/runsPlateforme/GaIIx/111125_HWUSI-EAS1884_00002_FC64F86AAXX/Ann-extract_Join"
}

# get the arguments of the command line
if [ $# -lt 6 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-inCAS | --inputCASAVA )         shift
					if [ "$1" != "" ]; then
						#ann-extract folder from CASAVA
						inCAS=$1
						#~ echo "inCAS: $inCAS"
					else
						usage
						exit
					fi
		                        ;;
		-inGATK | --inputGATK )         shift
					if [ "$1" != "" ]; then
						#ann-extract folder from GATK
						inGATK=$1
						#~ echo "inGATK: $inGATK"
					else
						usage
						exit
					fi
		                        ;;			                        
		-o | --output )         shift
					if [ "$1" != "" ]; then
						#Output folder Path
						output=$1
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

#Prepare Output
if [ -d $output ]; then
 echo -e "\n\tOUTPUT FOLDER: $output (folder already exist)" 
else
 mkdir -p $output
 echo -e "\n\tOUTPUT FOLDER : $output (folder created)"
fi
chmod -R 777 $output
#~ mkdir -p $output/"joinRapport"

#Parcourir le dossier ouput GATK et récupérer le fichier output CASAVA correspondant
	for GATKfile in `ls $inGATK | grep ".ann-extract"`
	do
	
		ind=$(echo $GATKfile | awk -F"_" '{print $1}')
		echo -e "\tSAMPLE: $ind";
	
		CASpath=$(echo `ls $inCAS/$ind*.ann-extract`)
		CASfile=$(echo $CASpath | awk -F"/" '{print $NF}')
		ligne=$(echo $CASfile | awk -F"_" '{print $2}')
		echo -e "\t\tGATKfile: "$GATKfile
		echo -e "\t\tCASfile: "$CASfile
		
		#Add pipeline tag
		#GATK
		awk -F'\t' 'BEGIN {OFS="\t"}{print "GATK\t"$0}' $inGATK/$GATKfile > $output/$GATKfile-gatk
		#CASAVA
		awk -F'\t' 'BEGIN {OFS="\t"}{print "CASAVA\t"$0}' $inCAS/$CASfile > $output/$CASfile-casava

		#Join + sort
		#header
		head -n 1 $output/$CASfile-casava > $output/$ind"_"$ligne".join-ann-extract"
		head -n 1 $output/$GATKfile-gatk >> $output/$ind"_"$ligne".join-ann-extract"
		#variants	sort (gene, gStart-gEnd, Pipeline)
		tail -n +2 -q $output/$CASfile-casava $output/$GATKfile-gatk | sort -k 6,6 -k 3,3 -k 1,1 >> $output"/"$ind"_"$ligne".join-ann-extract"
		echo -e "\t\tJoin file: "$ind"_"$ligne".join-ann-extract"
				
	done
		
		
		

