#!/bin/bash

#Script permettant, pour un run CASAVA donné, d'aller executer les commandes qualité
#L'output des fichiers annotés se fait dans un fichier Summary_Quality.csv à la racine du dossier Variants

#1 Préparer le fichier de sortie
touch Summary_Quality.csv
echo "Lane	Sample	ALL		1x		4x		10x		25x		50x		Mean" > Summary_Quality.csv
#Pour chaque Individu
for i in `ls | grep Project_`
do
	echo -e "\n--------------------------------------------------------------------------------------------------------------"
	echo "$i";
	for j in `ls $i | grep Sample_`
	do
		echo "-----------------"
		echo "$j - Compute mean depth"

		wcALL=`wc -l $i/$j/genome/depth/depth.bed`
		wc1=`wc -l $i/$j/genome/depth/sorted_D-inf1.bed`
		wc4=`wc -l $i/$j/genome/depth/sorted_D-inf4.bed`
		wc10=`wc -l $i/$j/genome/depth/sorted_D-inf10.bed`
		wc25=`wc -l $i/$j/genome/depth/sorted_D-inf25.bed`
		wc50=`wc -l $i/$j/genome/depth/sorted_D-inf50.bed`
		mean=`cat $i/$j/genome/depth/mean-depth.txt`

		echo "$i	$j	$wcALL	$wc1	$wc4	$wc10	$wc25	$wc50	$mean" >> Summary_Quality.csv

	done
done

