#!/bin/bash
#
# Sophie Coutant
# LAST UPDATE : 31/06/2016
#

# usage
function usage
{
	echo "#----------------------------------------------------------------------------------------------------------#"
	echo "#Elandv2e needs several input files and a specific folder structure. This script :                         #"
	echo "#     - generate the 2 necessary xml files : DemultiplexBustardSummary.xml & DemultiplexBustardConfig.xml  #"
	echo "#     - organise a folder with the proper structure                                                        #"
	echo "#It must be execuded from the runFolder                                                                    #"
	echo "#----------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: switch2casava.sh -sSheet <file> -runFold <dir> -project <text> -cap <capture> -dem <dir> -out <dir>" 
	echo "	-sSheet <path to sampleSheet file>"
	echo "	-runFold <path to run folder>"
	echo "	-project <project>"	
	echo "	-cap <capture>"	
	echo "	-dem <bcl2fastq ouput folder>"
	echo "	-out <Casava unaligned folder>"
	echo "EXAMPLE: ./switch2casava.sh -sSheet /storage/crihan-msa/RunsPlateforme/NextSeq/SampleSheet_Config/160504/SampleSheet.csv -runFold /storage/crihan-msa/RunsPlateforme/NextSeq/160504_NB501076_0013_AH7LF5AFXX -project RunColonNS5 -cap ONCO -dem UnalignedRunColonNS5_dem -out UnalignedRunColonNS5"
	echo " "
}


# get the arguments of the command line
if [ $# -lt 12 ]; then
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
		-cap | --project )    	shift
					if [ "$1" != "" ]; then
						capture=$1
					else
						usage
						exit
					fi
		                        ;;
		-dem | --dem )    	shift
					if [ "$1" != "" ]; then
						dem=$1
					else
						usage
						exit
					fi
		                        ;;
		-out | --out )    	shift
					if [ "$1" != "" ]; then
						Unaligned=$1
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

if [ -d $Unaligned ]; then
 echo -e "\n\tOUTPUT FOLDER: $Unaligned (folder already exist)" 
else
 mkdir -p $Unaligned
 echo -e "\n\tOUTPUT FOLDER : $Unaligned (folder created)"
fi

#DemultiplexedBustardSummary.xml
	echo -e "\nDemultiplexedBustardSummary.xml creation..."
	
	if [ -f $$Unaligned/DemultiplexedBustardSummary.xml ]; then
		rm $Unaligned/DemultiplexedBustardSummary.xml
	fi
	touch $Unaligned/DemultiplexedBustardSummary.xml
	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> $Unaligned/DemultiplexedBustardSummary.xml
	echo "<BustardSummary>" >> $Unaligned/DemultiplexedBustardSummary.xml
	echo "  <Software>CASAVA-1.8.2</Software>" >> $Unaligned/DemultiplexedBustardSummary.xml
	echo "</BustardSummary>" >> $Unaligned/DemultiplexedBustardSummary.xml
	
	echo -e "DemultiplexedBustardSummary.xml done"


#DemultiplexedBustardConfig.xml
echo -e "\nDemultiplexedBustardConfig.xml creation..."
cp $runFold"/Data/Intensities/BaseCalls/config.xml" $Unaligned/DemultiplexedBustardConfig.tmp
realNbReads=$(grep -c "<Reads Index=" $Unaligned/DemultiplexedBustardConfig.tmp)

#If more than 2 reads -> need to mask index reads from the file
if [ $realNbReads -gt 2 ]; then

	for ((read=2; read<$realNbReads; read++)); do
		#get Index read line
		readLine=$(grep -n "<Reads Index=\"$read\">" $Unaligned/DemultiplexedBustardConfig.tmp | cut -f 1 -d:)
		readLine2=$(( $readLine + 4 ))
		#replace both <Reads>..</Reads> node
		sed -i -e s/"<Reads Index=\"$read\""/"<ReadsIgnore Index=\"$read\""/g $Unaligned/DemultiplexedBustardConfig.tmp
		sed -i -e "${readLine2}s/Reads/ReadsIgnore/" $Unaligned/DemultiplexedBustardConfig.tmp
	done
	
	#replace the last read Index by Index 2
	sed -i -e s/"<Reads Index=\"$realNbReads\""/"<Reads Index=\"2\""/g $Unaligned/DemultiplexedBustardConfig.tmp
	mv $Unaligned/DemultiplexedBustardConfig.tmp $Unaligned/DemultiplexedBustardConfig.xml
else
	mv $Unaligned/DemultiplexedBustardConfig.tmp $Unaligned/DemultiplexedBustardConfig.xml
fi
echo -e "DemultiplexedBustardConfig.xml done"

#Generate old SampleSheet Model :
	#FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
	#000000000-AY2U9,1,17-00219,,TAAGGCGA-TATCCTCT,,,,ND,MS01Run169-HYCOS23
	#000000000-AY2U9,1,16-13676,,CGTACTAG-TATCCTCT,,,,ND,MS01Run169-HYCOS23
echo "FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject" > $Unaligned/SampleSheet.csv
FCID=$(echo $runFold | awk -F"_" '{print $NF}');
Lane="1"
SampleRef=""
Description=""
Control=""
Recipe=""

for file in `ls $runFold/$dem/Project_$capture/ | grep "R1"`; 
do 
	#FASTQ Symbolic link and folder structure
	ind=$(echo $file | awk -F"_" '{print $1}');
	SampleProject=$(grep $ind $sSheet | awk -F"," '{print $10}')
	mkdir -p $Unaligned"/Project_"$SampleProject"/Sample_"$ind
	
	#SampleSheet
	SampleID=$ind
	Operator=$(grep $ind $sSheet | awk -F"," '{print $11}')
	Index1=$(grep $ind $sSheet | awk -F"," '{print $6}')
	Index2=$(grep $ind $sSheet | awk -F"," '{print $8}')
	
	if [ "$Index2" != "" ]; then
		#doubleIndex
		echo "$FCID,$Lane,$SampleID,$SampleRef,$Index1-$Index2,$Description,$Control,$Recipe,$Operator,$SampleProject" >> $Unaligned/SampleSheet.csv
		ln -s $runFold"/"$dem"/Project_"$capture"/"$ind*"R1_001.fastq.gz" $Unaligned"/Project_"$SampleProject"/Sample_"$ind"/"$ind"_"$Index1"-"$Index2"_L00"$Lane"_R1_001.fastq.gz"
		ln -s $runFold"/"$dem"/Project_"$capture"/"$ind*"R2_001.fastq.gz" $Unaligned"/Project_"$SampleProject"/Sample_"$ind"/"$ind"_"$Index1"-"$Index2"_L00"$Lane"_R2_001.fastq.gz"
	else
		#simpleIndex
		echo "$FCID,$Lane,$SampleID,$SampleRef,$Index1,$Description,$Control,$Recipe,$Operator,$SampleProject" >> $Unaligned/SampleSheet.csv
		ln -s $runFold"/"$dem"/Project_"$capture"/"$ind*"R1_001.fastq.gz" $Unaligned"/Project_"$SampleProject"/Sample_"$ind"/"$ind"_"$Index1"_L00"$Lane"_R1_001.fastq.gz"
		ln -s $runFold"/"$dem"/Project_"$capture"/"$ind*"R2_001.fastq.gz" $Unaligned"/Project_"$SampleProject"/Sample_"$ind"/"$ind"_"$Index1"_L00"$Lane"_R2_001.fastq.gz"
	fi
done

echo -e "\nTIME: END SWITCH2CASAVA SETTINGS CREATOR ".`date`
