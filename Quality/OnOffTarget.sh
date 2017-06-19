#!/bin/bash

#Script permettant, pour un run CASAVA donné, d'aller executer les commandes qualité d'on-off target
#L'output des fichiers annotés se fait dans un dossier depth

#verifie la presence d'un argument
if [ $# -lt 1 ]
then
	echo "Erreur: veuillez donner en argument le nom du fichier bed (Agilent)";	
	echo "Exemples: ";
	echo -e "\tDiag: /opt/pipeline_NGS/Quality/OnOffTarget.sh /storage/crihan-msa/RunsPlateforme/Reference/Capture/MMR/036540_D_BED_20110915-DiagK_colique-U614_TARGET.bed";
	echo -e "\tExome: /opt/pipeline_NGS/Quality/OnOffTarget.sh /storage/crihan-msa/RunsPlateforme/Reference/Capture/Exome/BED/V4_S03723314_Target.bed";
	exit 2;
fi

bed=$1;

#1 Préparer le fichier de sortie
touch Summary_OnOffTarget.csv
echo "Lane	Sample	AllMapped	OnTarMapped	CaptureSize	CoveredNuclOnCapture" > Summary_OnOffTarget.csv
#Pour chaque Individu
for i in `ls | grep Project_`
do
	echo -e "\n--------------------------------------------------------------------------------------------------------------"
	echo "$i";
	for j in `ls $i | grep Sample_`
	do
		echo "-----------------"
		echo "$j"
		AllMap=`samtools flagstat $i/$j/genome/bam/sorted.bam | head -n -8 | tail -n -1 | cut -d " " -f 1`
		AllCap=`cat $bed | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}'`
		echo "All Mapped: $AllMap | Capture Size: $AllCap"
		
		TarMap=`samtools view -b $i/$j/genome/bam/sorted.bam | $bedtoolsdir/coverageBed -abam stdin -b $bed | awk '{SUM+=$4} END {print SUM}';`
		CovNucl=`samtools view -b $i/$j/genome/bam/sorted.bam | $bedtoolsdir/coverageBed -abam stdin -b $bed | awk '{SUM+=$5} END {print SUM}';`
		echo "On-target Mapped: $TarMap | Covered Nucleotide On Capture: $CovNucl"

		echo "$i	$j	$AllMap	$TarMap	$AllCap	$CovNucl" >> Summary_OnOffTarget.csv
	done
done
