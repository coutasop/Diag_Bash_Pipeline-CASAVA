#!/bin/bash
#
# Sophie COUTANT
# 23/07/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# This script allows the parsing of the annovar output to generate a standard input for EVA                                                                  #
#                                                                                                                                                            #
# 1- Parsing of the OtherInfo column                                                                                                                         #
# 2- Column names change                                                                                                                                     #
# 3- Column values change                                                                                                                                    #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# usage
function usage
{
    echo "USAGE: parsing_annovarOutput.sh -d <directory> -c <CASAVA/GATK/Samtools>"
	echo "       -d <annovar output directory containing multianno.txt files>"
    echo "       -c <CASAVA/GATK/Samtools> (variant calling tool used to produce the variant calling file)"
    echo "EXAMPLE: ./parsing_annovarOutput.sh -d Project/Annotated -c GATK"
}

# get the arguments of the command line
if [ $# -lt 2 ]; then
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
		                        
		-c | --caller )         shift
					if [ "$1" != "" ]; then
						# fileType <CASAVA/GATK/Samtools>
						fileFormat=$1
						if [[ $fileFormat = "CASAVA" ]]; then
							caller="CASAVA"
	
						elif [[ $fileFormat = "GATK" ]]; then
							caller="GATK"
							
						elif [[ $fileFormat = "Samtools" ]]; then
							caller="Samtools"
						else
							echo "Only CASAVA, GATK or Samtools are supported!"
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
	echo -e "\t   #CMD: $chemin_script/parsing_annovarOutput_otherInfo.sh -f $multianno -c $caller"
	$chemin_script/parsing_annovarOutput_otherInfo.sh -f $multianno -c $caller

	echo -e "\t 2- Column names change"
	#Sed Remplacer nom de colonnes
	#sed '1 c\ chrom\tgPosStart\tgPosEnd\tref\talt\tFunc.refGene\tGene.refGene\tExonicFunc.refGene\tAAChange.refGene\tLJB2_SIFT\tLJB2_PolyPhen2_HDIV\tLJB2_PP2_HDIV_Pred\tLJB2_PolyPhen2_HVAR\tLJB2_PolyPhen2_HVAR_Pred\tLJB2_LRT\tLJB2_LRT_Pred\tLJB2_MutationTaster\tLJB2_MutationTaster_Pred\tLJB_MutationAssessor\tLJB_MutationAssessor_Pred\tLJB2_FATHMM\tLJB2_GERP++\tLJB2_PhyloP\tLJB2_SiPhy\tcosmic64\tesp6500si_ea\tesp6500si_all\t1000g2012apr_eur\t1000g2012apr_all\tsnp137\tsnp137NonFlagged\tcytoband\twgRna\ttotalRead\tusedRead\tallelicBalance\tgenotypeStatus\taUsed\tcUsed\tgUsed\ttUsed\tindelRefUsed\tindelAltUsed' $fileNameTabSep_ACGT.txt 
	sed -e s/"Chr"/"chrom"/g -e s/"Start"/"gPosStart"/g -e s/"End"/"gPosEnd"/g -e s/"Ref"/"ref"/g -e s/"Alt"/"alt"/g -e s/"cytoBand"/"cytoband"/g $fileName"_TabSep_ACGT.txt" > $fileName"_TabSep_ACGT_header.txt"

	#Sed remplacer valeur des cellules
	#Transformer genotype status en het/hom
	echo -e "\t 3- Column values change"
	sed -e s/"1\/0"/"het"/g -e s/"0\/1"/"het"/g -e s/"1\/1"/"hom"/g $fileName"_TabSep_ACGT_header.txt" > $fileName".EVAnnot"

	#Suppression fichiers devenus inutile
	rm $fileName"_TabSep_ACGT.txt" 
	rm $fileName"_TabSep_ACGT_header.txt"
	
	echo -e "\t #DONE - #Output $fileName.EVAnnot"
done
echo -e "\t TIME: END PARSING ".`date`
