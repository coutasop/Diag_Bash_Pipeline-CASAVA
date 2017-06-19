#!/bin/bash

#Script permettant, pour un run CASAVA donné, d'aller executer les commandes qualité
#L'output des fichiers annotés se fait dans un dossier depth 

#verifie la presence d'un argument
if [ $# -lt 1 ]
then
	echo "Erreur: veuillez donner en argument le nom du fichier bed (Agilent)";	
	echo "Exemples: ";
	echo -e "\tDiag: /opt/pipeline_NGS/Quality/Quality.sh /storage/crihan-msa/RunsPlateforme/Reference/Capture/MMR/036540_D_BED_20110915-DiagK_colique-U614_TARGET.bed";
	echo -e "\tExome: /opt/pipeline_NGS/Quality/Quality.sh /storage/crihan-msa/RunsPlateforme/Reference/Capture/Exome/BED/V4_S03723314_Target.bed";
	exit 2;
fi

bed=$1;
scriptPath=$(dirname $0) #Get the folder path of this script

#Pour chaque Individu
for i in `ls | grep Project_`
do
	echo -e "\n--------------------------------------------------------------------------------------------------------------"
	echo "$i";
	for j in `ls $i | grep Sample_`
	do
		echo "-----------------"
		echo "$j"
		#execute les calculs profondeur
		#mkdir $i/$j/genome/depth;
		chmod -R 777 $i/$j/genome/depth
		samtools depth -d 10000000 -b $bed $i/$j/genome/bam/sorted.bam > $i/$j/genome/depth/depth.bed;
		echo "Mean Depth"
		cat $i/$j/genome/depth/depth.bed | awk '{ sum += $3 } END { print (sum / NR)}' > $i/$j/genome/depth/mean-depth.txt;
		echo "Depth 1x"
		cat $i/$j/genome/depth/depth.bed | awk '$3 <= 1 {print "chr"$1" "$2" "$3}' > $i/$j/genome/depth/sorted_D-inf1.bed;
		echo "Depth 4x"
		cat $i/$j/genome/depth/depth.bed | awk '$3 <= 4 {print "chr"$1" "$2" "$3}' > $i/$j/genome/depth/sorted_D-inf4.bed;
		echo "Depth 10x"
		cat $i/$j/genome/depth/depth.bed | awk '$3 <= 10 {print "chr"$1" "$2" "$3}' > $i/$j/genome/depth/sorted_D-inf10.bed;
		echo "Depth 25x"
		cat $i/$j/genome/depth/depth.bed | awk '$3 <= 25 {print "chr"$1" "$2" "$3}' > $i/$j/genome/depth/sorted_D-inf25.bed;
		echo "Depth 50x"
		cat $i/$j/genome/depth/depth.bed | awk '$3 <= 50 {print "chr"$1" "$2" "$3}' > $i/$j/genome/depth/sorted_D-inf50.bed;
	done
done
$scriptPath/Quality_summary.sh
