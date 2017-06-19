#!/bin/bash

#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Script permettant, pour un run donné, de générer le fichier DoublePipelineAllQual.csv                                                                      #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# Script permettant, pour un run donné, de générer le fichier DoublePipelineAllQual.csv                                                                      #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
    echo -e "\nUSAGE: DoublePipelineAllQual.sh -gatkBam <folder> -casavaVariant <folder> -bed <file> -o <outputpath>"
    echo "		 -gatkDir <GATK analyse Folder>"
    echo "		 -bed <Agilent Target bed file>"
    echo "		 -o <outputpath>"
    echo -e "\nEXAMPLE: ./DoublePipelineAllQual.sh -gatkDir /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX/BWA-GATK_RunDiag1 -casavaVariant /storage/IN/111125_HWUSI-EAS1884_00002_FC64F86AAXX/VariantsRunDiag1 -bed /storage/IN/Reference/Capture/MMR/036540_D_BED_20110915-DiagK_colique-U614_TARGET.bed"
    echo -e "\nREQUIREMENT: Samtools must be installed and in your PATH\n"
}

# get the arguments of the command line
if [ $# -lt 6 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-gatkDir | --gatkDir )         shift
					if [ "$1" != "" ]; then
						gatkDir=$1
					else
						usage
						exit
					fi
		                        ;;
		-bed | --bedFile )         shift
					if [ "$1" != "" ]; then
						#bedFile path
						bed=$1
					else
						usage
						exit
					fi
		                        ;;
		-o | --out )         shift
					if [ "$1" != "" ]; then
						out=$1
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

if [ -d $out ]; then
 echo -e "\n\tOUTPUT FOLDER: $out (folder already exist)" 
 chmod 777 $out
else
 mkdir -p $out
 echo -e "\n\tOUTPUT FOLDER : $out (folder created)"
fi
echo "ind	CASATotRead	GATKTotRead	CASAAllMap	CASAalnP GATKAllMap	GATKAllMap	GATKSecMap	GATKUniqMap	GATKalnP	CASAmean	GATKmean	AllCap	CASATarMap	GATKTarMap	CASACovNucl	 GATKCovNucl	CASAVA1P	CASAVA5P	CASAVA30P	CASAVA50P	CASAVA100P	GATK1P	GATK5P	GATK30P	GATK50P	GATK100P" > $out/DoublePipelineAllQual.csv
scriptPath=$(dirname $0) #Get the folder path of this script

#General Metrics (BED dependant)
AllCap=`awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}' $bed`
echo "Capture Size: $AllCap"

#Individual Metrics
#~ for i in `ls $casavaVariant | grep Project_`
#~ do
	#~ echo -e "\n--------------------------------------------------------------------------------------------------------------"
	#~ echo "$i";
	for j in `ls $gatkDir/FASTQ/ | grep "R1.fastq.gz"`
	do
		echo "-----------------------"
		echo "$j"

		ind=$(echo $j | awk -F"_" '{print $1}')
		
		#execute les calculs profondeur uniquement si besoin (si les fichiers n'existe pas déjà)
		if [ -d $gatkDir/DEPTH ]; then
			echo -e "\tOUTPUT FOLDER : $gatkDir/DEPTH (folder created)"
			sudo chmod -R 777 $gatkDir/DEPTH		#creation du repertoire depth s'il n'existe pas
		else
			mkdir $gatkDir/DEPTH;					#s'il existe s'assurer des droits
		fi
		if [ -f $gatkDir/DEPTH/$ind_depth.bed ]; then
			echo -e "\tSKIP DEPTH: file exists already"
		else
			echo -e "\tDEPTH per base: processing"
			samtools depth -d 10000000 -b $bed $gatkDir/DEPTH/$ind.sorted.dedup.withRG.real.BQSR.bam > $gatkDir/DEPTH/$ind_depth.bed;
		fi
		
		#~ echo -e "\t-Compute CASAVA metrics-"
		#~ CASAmean=`awk '{ sum += $3 } END { print (sum / NR)}' $casavaVariant/$i/$j/genome/depth/depth.bed`
		#~ CASAall=`wc -l $casavaVariant/$i/$j/genome/depth/depth.bed | cut -d\  -f1`
		#~ CASA1=`awk '$3 <= 1 {print "chr"$1" "$2" "$3}' $casavaVariant/$i/$j/genome/depth/depth.bed | wc -l`
		#~ CASA5=`awk '$3 <= 5 {print "chr"$1" "$2" "$3}' $casavaVariant/$i/$j/genome/depth/depth.bed | wc -l`
		#~ CASA30=`awk '$3 <= 30 {print "chr"$1" "$2" "$3}' $casavaVariant/$i/$j/genome/depth/depth.bed | wc -l`
		#~ CASA50=`awk '$3 <= 50 {print "chr"$1" "$2" "$3}' $casavaVariant/$i/$j/genome/depth/depth.bed | wc -l`
		#~ CASA100=`awk '$3 <= 100 {print "chr"$1" "$2" "$3}' $casavaVariant/$i/$j/genome/depth/depth.bed | wc -l`
		#~ echo "TMP1: $CASAall $CASA1	$CASA5	$CASA30	$CASA50	$CASA100"
		
				
		#~ CASA1P=`echo "scale=2; ($CASAall-$CASA1)*100/$CASAall" | bc`
		#~ CASA5P=`echo "scale=2; ($CASAall-$CASA5)*100/$CASAall" | bc`
		#~ CASA30P=`echo "scale=2; ($CASAall-$CASA30)*100/$CASAall" | bc`
		#~ CASA50P=`echo "scale=2; ($CASAall-$CASA50)*100/$CASAall" | bc`
		#~ CASA100P=`echo "scale=2; ($CASAall-$CASA100)*100/$CASAall" | bc`
		#~ echo "TMP2: $CASAall $CASA1P	$CASA5P	$CASA30P	$CASA50P	$CASA100P"
		
		#~ CASATotRead=`samtools flagstat $casavaVariant/$i/$j/genome/bam/sorted.bam | grep "paired in sequencing" | cut -d " " -f 1`
		#~ CASAAllMap=`samtools flagstat $casavaVariant/$i/$j/genome/bam/sorted.bam | grep "mapped (" | cut -d " " -f 1`
		#~ CASATarMap=`coverageBed -abam $casavaVariant/$i/$j/genome/bam/sorted.bam -b $bed | awk '{SUM+=$4} END {print SUM}';`
		#~ CASACovNucl=`coverageBed -abam $casavaVariant/$i/$j/genome/bam/sorted.bam -b $bed | awk '{SUM+=$5} END {print SUM}';`
		#~ echo -e "\tCASAVA : MeanDepth: $CASAmean | CASATotRead: $CASATotRead | CASAAllMap: $CASAAllMap | On-target Mapped: $CASATarMap | Covered Nucleotide On Capture: $CASACovNucl"
		
		
		echo -e "\t-Compute GATK metrics-"
		GATKmean=`awk '{ sum += $3 } END { print (sum / NR)}' $gatkDir/DEPTH/$ind"_depth.bed"`
		GATKall=`wc -l $gatkDir/DEPTH/$ind"_depth.bed" | cut -d\  -f1`
		GATK1=`awk '$3 <= 1 {print "chr"$1" "$2" "$3}' $gatkDir/DEPTH/$ind"_depth.bed" | wc -l`
		GATK5=`awk '$3 <= 5 {print "chr"$1" "$2" "$3}' $gatkDir/DEPTH/$ind"_depth.bed" | wc -l`
		GATK30=`awk '$3 <= 30 {print "chr"$1" "$2" "$3}' $gatkDir/DEPTH/$ind"_depth.bed" | wc -l`
		GATK50=`awk '$3 <= 50 {print "chr"$1" "$2" "$3}' $gatkDir/DEPTH/$ind"_depth.bed" | wc -l`
		GATK100=`awk '$3 <= 100 {print "chr"$1" "$2" "$3}' $gatkDir/DEPTH/$ind"_depth.bed" | wc -l`
		#~ echo "TMP3: $GATKall	$GATK1	$GATK5	$GATK30	$GATK50	$GATK100"
				
		GATK1P=`echo "scale=2; ($GATKall-$GATK1)*100/$GATKall" | bc`
		GATK5P=`echo "scale=2; ($GATKall-$GATK5)*100/$GATKall" | bc`
		GATK30P=`echo "scale=2; ($GATKall-$GATK30)*100/$GATKall" | bc`
		GATK50P=`echo "scale=2; ($GATKall-$GATK50)*100/$GATKall" | bc`
		GATK100P=`echo "scale=2; ($GATKall-$GATK100)*100/$GATKall" | bc`
		#~ echo "TMP4: $GATKall	$GATK1P	$GATK5P	$GATK30P	$GATK50P	$GATK100P"
		
		GATKTotRead=`samtools flagstat $gatkDir/BAM/$ind".sorted.dedup.withRG.real.BQSR.bam" | grep "paired in sequencing" | cut -d " " -f 1`
		GATKSecMap=`samtools flagstat $gatkDir/BAM/$ind".sorted.dedup.withRG.real.BQSR.bam" | grep "secondary" | cut -d " " -f 1`
		GATKAllMap=`samtools flagstat $gatkDir/BAM/$ind".sorted.dedup.withRG.real.BQSR.bam" | grep "mapped (" | cut -d " " -f 1`
		GATKUniqMap=`echo "scale=2; $GATKAllMap-$GATKSecMap" | bc`
		GATKTarMap=`coverageBed -abam $gatkDir/BAM/$ind".sorted.dedup.withRG.real.BQSR.bam" -b $bed | awk '{SUM+=$4} END {print SUM}';`
		GATKCovNucl=`coverageBed -abam $gatkDir/BAM/$ind".sorted.dedup.withRG.real.BQSR.bam" -b $bed | awk '{SUM+=$5} END {print SUM}';`
		echo -e "\tGATK : MeanDepth: $GATKmean | GATKTotRead: $GATKTotRead | AllMapped: $GATKAllMap | GATKUniqMap: $GATKUniqMap | GATKalnP: $GATKalnP | On-target Mapped: $GATKTarMap | Covered Nucleotide On Capture: $GATKCovNucl"

		#~ CASAalnP=`echo "scale=2; $CASAAllMap*100/$GATKTotRead" | bc`
		GATKalnP=`echo "scale=2; $GATKUniqMap*100/$GATKTotRead" | bc`
		
		echo "$ind	$CASATotRead	$GATKTotRead $CASAAllMap	$CASAalnP $GATKAllMap	$GATKAllMap	$GATKSecMap	$GATKUniqMap	$GATKalnP	$CASAmean	$GATKmean	$AllCap	$CASATarMap	$GATKTarMap	$CASACovNucl	 $GATKCovNucl	$CASA1P	$CASA5P	$CASA30P	$CASA50P	$CASA100P	$GATK1P	$GATK5P	$GATK30P	$GATK50P	$GATK100P" >> $out/DoublePipelineAllQual.csv
		
	done
done

