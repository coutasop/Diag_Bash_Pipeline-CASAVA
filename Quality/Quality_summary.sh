#!/bin/bash

#Script permettant, pour un run CASAVA donné, d'aller executer les commandes qualité
#L'output des fichiers annotés se fait dans un fichier Summary_Quality.csv à la racine du dossier Variants

#1 Préparer le fichier de sortie
touch Summary_Quality.csv
echo "Lane	Sample	ALL	1x	1x(%)	4x	4x(%)	10x	10x(%)	25x	25x(%)	50x	50x(%)	Mean" > Summary_Quality.csv
#Pour chaque Individu
for i in `ls | grep Project_`
do
	echo -e "\n--------------------------------------------------------------------------------------------------------------"
	echo "$i";
	for j in `ls $i | grep Sample_`
	do
		echo "-----------------"
		echo "$j - Compute mean depth"
		
		lane=`echo $i | cut -d_ -f4`
		sample=`echo $j | cut -d_ -f2`
		wcALL=`wc -l $i/$j/genome/depth/depth.bed | cut -d\  -f1`
		wc1=`wc -l $i/$j/genome/depth/sorted_D-inf1.bed | cut -d\  -f1`
		wc1P=`echo "scale=2; ($wcALL-$wc1)*100/$wcALL" | bc`
		wc4=`wc -l $i/$j/genome/depth/sorted_D-inf4.bed | cut -d\  -f1`
		wc4P=`echo "scale=2; ($wcALL-$wc4)*100/$wcALL" | bc`
		wc10=`wc -l $i/$j/genome/depth/sorted_D-inf10.bed | cut -d\  -f1`
		wc10P=`echo "scale=2; ($wcALL-$wc10)*100/$wcALL" | bc`
		wc25=`wc -l $i/$j/genome/depth/sorted_D-inf25.bed | cut -d\  -f1`
		wc25P=`echo "scale=2; ($wcALL-$wc25)*100/$wcALL" | bc`
		wc50=`wc -l $i/$j/genome/depth/sorted_D-inf50.bed | cut -d\  -f1`
		wc50P=`echo "scale=2; ($wcALL-$wc50)*100/$wcALL" | bc`
		mean=`cat $i/$j/genome/depth/mean-depth.txt`

		echo "$lane	$sample	$wcALL	$wc1	$wc1P	$wc4	$wc4P	$wc10	$wc10P	$wc25	$wc25P	$wc50	$wc50P	$mean" >> Summary_Quality.csv

	done
done

