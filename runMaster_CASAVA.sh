#!/bin/bash
#
# Sophie
# LAST UPDATE : 06/06/2014
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Ce script permet le lancement automatique du pipeline CASAVA                                                                                               #
# Etape:                                                                                                                                                     #
# 1- Lancer Demultiplexage                                                                                                                                   #
# 2- Lancer Alignement                                                                                                                                       #
# 3- Lancer Variant-Calling			                                                                                                                         #
# 4- Lancer autoAnnot 			                                                                                                                             #
# 5- Lancer join Rapport Excel                                                                                                                               #
# 6- Lancer Global quality		                                                                                                                             #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------------#
#-------------------------USAGE AND PARAMETERS-------------------------#
#----------------------------------------------------------------------#

# usage
function usage
{
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo "# Ce script permet le lancement automatique du pipeline CASAVA                                                                                               #"
	echo "# Etape:                                                                                                                                                     #"
	echo "# 1- Lancer Demultiplexage                                                                                                                                   #"
	echo "# 2- Lancer Alignement                                                                                                                                       #"
	echo "# 3- Lancer Variant-Calling                                                                                                                                  #"
	echo "# 4- Lancer autoAnnot                                                                                                                                        #"
	echo "# 5- Lancer join Rapport Excel                                                                                                                               #"
	echo "# 6- Lancer Global quality                                                                                                                                   #"
	echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
	echo " "
	echo "USAGE: runMaster_CASAVA.sh -s <file>" 
	echo "	-s <path to settings file>"
	echo "EXAMPLE: ./run_CASAVA.sh -s path/to/CASAVA-settings.txt"
	echo -e "\nREQUIREMENT: CASAVA must be installed"
	echo -e "\tSettings for the programs and data must be set the setting file provided as an argument\n"
	echo " "
}

# get the arguments of the command line
if [ $# -lt 2 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-s | --settings )    	shift
					if [ "$1" != "" ]; then
						settingsFile=$1
					else
						usage
						exit
					fi
		                        ;;     
	    esac
	    shift
	done
fi

echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"
echo "# Ce script permet le lancement automatique du pipeline CASAVA                                                                                               #"
echo "# Etape:                                                                                                                                                     #"
echo "# 1- Lancer Demultiplexage                                                                                                                                   #"
echo "# 2- Lancer Alignement                                                                                                                                       #"
echo "# 3- Lancer Variant-Calling                                                                                                                                  #"
echo "# 4- Lancer autoAnnot                                                                                                                                        #"
echo "# 5- Lancer join Rapport Excel                                                                                                                               #"
echo "# 6- Lancer Global quality                                                                                                                                   #"
echo "#------------------------------------------------------------------------------------------------------------------------------------------------------------#"

#----------------------------------------------------------------------#
#-----------------READ SETTINGS AND OUTPUT FOLDER CHECK----------------#
#----------------------------------------------------------------------#

#Get the paths and names of all the scripts and datas that will be launched
scriptPath=$(dirname $0) #Get the folder path of this script
source $settingsFile	 #Import the settings

#Avant de lancer le pipeline il faut attendre que le Run Folder soit complet
	#Fichier à verifier pour savoir si la copie est terminé
	copied="copy.completed"
	#while the copy file does not exist continue to check
	while [ ! -f $runFolder/$copied ]; 
	do
		echo -e "WAIT 15min : File $runFolder/$copied doesn't exists"
		sleep 15m
	done

#----------------------------------------------------------------------#
#---------------------------PIPELINE BEGIN-----------------------------#
#----------------------------------------------------------------------#
echo -e "\n#----------------------------PIPELINE BEGIN------------------------------#";
date
#prepare runFolder
chmod 777 $runFolder


#----------------------------------------------------------------------#
#--0--# OFFLINE BASE CALLER:
if [ $doOLB = "y" ]; 
then  
	echo -e "\n#--0--# OFFLINE BASE CALLER:"
	cd $intensdir
	echo -e "\tCOMMAND: $OLBdir/bustard.py --CIF $intensdir --make"
	$OLBdir/bustard.py --CIF $intensdir --make
	bustardDir=$(echo `ls $intensdir/ | grep "^Bustard"`)				#Bustard.* dir (le folder créé par OLB) 
	datadir=$intensdir"/"$bustardDir									#il doit écraser le datadir du fichier setting pour que le demultiplexage se passe correctement
	chmod -R 777 $datadir
	cd $datadir
	echo -e "\tCOMMAND: make recursive -j $maxthreads"
	make recursive -j $maxthreads
else
	echo -e "\nSKIP: #--0--# OFFLINE BASE CALLER"
fi

#----------------------------------------------------------------------#
#--1--# DEMULTIPLEXAGE:
if [ $doDEM = "y" ]; 
then  
	echo -e "\n#--1--# DEMULTIPLEXAGE:"

	#BCL2FASTQ2
	#Check si le dossier de bcl2fastq2 est défini dans les settings
	if [ $bcl2fastq2dir"set" != "set" ] #si oui => bcl2fastq2
	#~ if [ $sequencer = "NextSeq" ]; 
	then
		echo -e "\tNextSeq Sequencer : demultiplexing by bcl2fastq2"
		echo -e "\tCOMMAND: $bcl2fastq2dir/bcl2fastq -R $runFolder -o $unaligneddir --sample-sheet $sampleSheetFile --minimum-trimmed-read-length 76"
		$bcl2fastq2dir/bcl2fastq -R $runFolder -o $unaligneddir"_dem" --sample-sheet $sampleSheetFile --minimum-trimmed-read-length 76
		touch $unaligneddir"_dem"/demultiplexing.completed
		cp $sampleSheetFile $runFolder/SampleSheet.csv

		#output folder creation
		if [ -d $unaligneddir/Project_$project ]; then
		 echo -e "\n\tOUTPUT FOLDER: $unaligneddir/Project_$project (folder already exist)" 
		else
		 mkdir -p $unaligneddir/Project_$project
		 echo -e "\n\tOUTPUT FOLDER : $unaligneddir/Project_$project (folder created)"
		fi
		#~ cd $unaligneddir/Project_$project
	
		#BAPT Switch2CASAVA
		cd $runFolder
		#Generate Settings
		echo -e "\nGenerate BAPT Switch2CASAVA Settings"
		echo -e "\tCOMMAND: $pipedir/switch2casava-settings-creator.sh -sSheet $sampleSheetFile -runFold $runFolder -project $project"
		$pipedir/switch2casava-settings-creator.sh -sSheet $sampleSheetFile -runFold $runFolder -project $project
		#Launch Switch2CASAVA
		echo -e "\nBAPT Switch2CASAVA"
		echo -e "\tCOMMAND: java -jar /opt/BAPT/BAPT.jar -c $BAPTsettings -t switchToCASAVA"
		java -jar /opt/BAPT/BAPT.jar -c "BAPT_Config-"$project"_SwitchToCASAVA.xml" -t switchToCASAVA

		#Creation du fichier siganlant au pipeline BWA-GATK que le démultiplexage est fini
		touch $unaligneddir/demultiplexing.completed
		echo -e "\nDemultiplexing completed"

	#BCL2FASTQ1	
	else	#si non => bcl2fastq1 (est dans le dossier casava)
		cd $datadir
		echo -e "\tNot a NextSeq Sequencer : demultiplexing by bcl2fastq"
		echo -e "\tCOMMAND: source $casavadir/configureBclToFastq.pl --input-dir $datadir --output-dir $unaligneddir --sample-sheet $sampleSheetFile"
		$casavadir/configureBclToFastq.pl --input-dir $datadir --output-dir $unaligneddir --sample-sheet $sampleSheetFile --use-bases-mask $basemask
		chmod -R 777 $unaligneddir
		cd $unaligneddir
		echo -e "\tCOMMAND: source make -j $maxthreads"
		make -j $maxthreads
		touch $unaligneddir/demultiplexing.completed
	fi
else
	echo -e "\nSKIP: #--1--# DEMULTIPLEXAGE"
fi


#----------------------------------------------------------------------#
#--2--# ALIGNEMENT: 
if [ $doALN = "y" ]; 
then  
	echo -e "\n#--2--# ALIGNEMENT:"
	echo -e "\tCOMMAND: source $casavadir/configureAlignment.pl $configFile --EXPT_DIR $unaligneddir --OUT_DIR $aligneddir --make"
	$casavadir/configureAlignment.pl $configFile --EXPT_DIR $unaligneddir --OUT_DIR $aligneddir --make
	chmod -R 777 $aligneddir
	cd $aligneddir
	echo -e "\tCOMMAND: source make -j $maxthreads all"
	make -j $maxthreads all
else
	echo -e "\nSKIP: #--2--# ALIGNEMENT"
fi

#----------------------------------------------------------------------#
#~ #--3--# VARIANT CALLING: 
if [ $doVC = "y" ]; 
then  
	echo -e "\n#--3--# VARIANT CALLING:"
	chmod -R 777 $aligneddir
	cd $aligneddir
	#Pour chaque Lane
	for i in `ls | grep Project_`
	do
		echo "--------------------------------------------------------------------------------------------------------------"
		echo "$i";
		echo "--------------------------------------------------------------------------------------------------------------"

		#Pour chaque Individu	
		for j in `ls $i | grep Sample_`
		do
			echo "-----------------"
			echo "$j"

			#Test if the output directory exists, if no, create it
			if [ -d $variantsdir/$i/$j ]; then
			 echo -e "\n\tOUTPUT FOLDER: $variantsdir/$i/$j (folder already exist)" 
			else
			 mkdir -p $variantsdir/$i/$j
			 echo -e "\n\tOUTPUT FOLDER : $variantsdir/$i/$j (folder created)"
			fi

			#execute le script de variant calling + target Bam
			$casavadir/configureBuild.pl --inSampleDir=$aligneddir/$i/$j/ --outDir=$variantsdir/$i/$j/ --jobsLimit $maxthreads --targets all bam --wa --variantsNoCovCutoff --samtoolsRefFile=$refdir/$myref
		done
		echo "--------------------------------------------------------------------------------------------------------------"
		echo ""
	done
else
	echo -e "\nSKIP: #--3--# VARIANT CALLING"
fi




#----------------------------------------------------------------------#
#--4--# ANNOTATION: 
if [ $doANN = "y" ]; 
then  
	echo -e "\n#--4--# ANNOTATION:"
	#If Exome:
	cd $runFolder
	if [ $analysisType = "Exome" ]; 
	then 
		echo -e "\tANNOVAR + EVANNOT:"
		echo -e "\tCOMMAND: $autoAnnotdir/run_annotExome.sh -c CASAVA -t exome -a $Annovardir -i $runFolder -o $annotdir -v $variantsdir -c2v $casava2vcfdir"
		$autoAnnotdir/run_annotExome.sh -c CASAVA -t exome -a $Annovardir -i $runFolder -o $annotdir -v $variantsdir -c2v $alamutHTdir
		
		echo -e "\tQUALITY"
		echo -e "\tApplication des droits dans $variantsdir ..."
		chmod -R 777 $variantsdir
		VariantsFolder=$(echo $variantsdir | awk 'BEGIN {FS="/"} {print $NF}')
		echo -e "\tRUNNING run_depthDiag.sh"
		echo -e "\t#CMD: $autoAnnotdir/run_depthDiag.sh -i $runFolder -bed $targets -v $VariantsFolder"
		$autoAnnotdir/run_depthDiag.sh -i $runFolder -bed $targets -v $VariantsFolder

	#If Diag
	elif [ $analysisType = "Diag" ]; 
	then 
		echo -e "\tAlamutHT:"
		echo -e "\tCOMMAND: $autoAnnotdir/run_annotDiag.sh -runFold $runFolder -glist $refdir/$gList -nm $refdir/$nmList -bed $refdir/$targetsDiagExtract -nbGa $numRunGa -nbDiag $numRunDiag -opGa $opGa -a $alamutHTdir -o $variantsdir"
		$autoAnnotdir/run_annotDiag.sh -runFold $runFolder -glist $refdir/$gList -nm $refdir/$nmList -bed $refdir/$targetsDiagExtract -nbGa $numRunGa -nbDiag $numRunDiag -opGa $opGa -a $alamutHTdir -o $variantsdir
		echo -e "\tQUALITY + RAPPORT:"
		echo -e "\tApplication des droits dans $variantsdir ..."
		chmod -R 777 $variantsdir
		echo -e "\tCOMMAND: $autoAnnotdir/run_qualDiag.sh -runFold $runFolder -agBed $refdir/$targets -bed $refdir/$targetsDiag -nbGa $numRunGa -nbDiag $numRunDiag -opGa $opGa -a $alamutHTdir -o $variantsdir"
		$autoAnnotdir/run_qualDiag.sh -runFold $runFolder -agBed $refdir/$targets -bed $refdir/$targetsDiag -nbGa $numRunGa -nbDiag $numRunDiag -opGa $opGa -a $alamutHTdir -o $variantsdir
	else
		echo "ERROR analysisType incorrect: must be Exome or Diag"
	fi
else
	echo -e "\nSKIP: #--4--# ANNOTATION"
fi

#----------------------------------------------------------------------#
#--5--# JOIN RAPPORT: 
if [ $doJOIN = "y" ]; 
then  
	echo -e "\n#--5--# JOIN RAPPORT:"
	cd $runFolder
	#Avant de lancer le join il faut attendre que le qual de GATK soit fini
	#Fichier à verifier pour savoir si GATK a terminé
	qual="qual.completed"
	#while the GATK qual file does not exist continue to check
	while [ ! -f $joinDir/$qual ]; 
	do
		echo -e "WAIT 5min : File $joinDir/$qual doesn't exists"
		sleep 5m
	done
	
	if [ -d $joinReportDir ]; then
	 echo -e "\n\tOUTPUT FOLDER: $joinReportDir (folder already exist)" 
	else
	 mkdir -p $joinReportDir
	 echo -e "\n\tOUTPUT FOLDER : $joinReportDir (folder created)"
	fi
	if [ -d $joinAnnExtractDir ]; then
	 echo -e "\n\tOUTPUT FOLDER: $outdir (folder already exist)" 
	else
	 mkdir -p $joinAnnExtractDir
	 echo -e "\n\tOUTPUT FOLDER : $outdir (folder created)"
	fi
	
	echo -e "\n  #--a--# Prepare Rapport:"
	echo -e "\t  COMMAND: $autoAnnotdir/run_joinAnnExtract-2pipelines.sh -inCAS $variantsdir/Result_alamutHT/Fbrut -inGATK $GATKextractDir -o $joinAnnExtractDir"
	$autoAnnotdir/run_joinAnnExtract-2pipelines.sh -inCAS $variantsdir/Result_alamutHT/Fbrut -inGATK $GATKextractDir -o $joinAnnExtractDir
	cp $variantsdir/Result_alamutHT/Fbrut/Quality.txt $joinDir/QualityCASAVA.txt
	
	echo -e "\n  #--b--# Java Rapport Variant:"
	echo -e "\t  COMMAND: java -jar $autoAnnotdir/Rapport_Variants_CasavaGATK.jar $runFolder/ $numRunGa $numRunDiag $opGa $TP53file $feuilleRouteFile $refdir/$geneNmList $refdir/$polList $joinAnnExtractDir $joinReportDir"
	java -jar $autoAnnotdir/Rapport_Variants_CasavaGATK.jar $runFolder/ $numRunGa $numRunDiag $opGa $TP53file $feuilleRouteFile $refdir/$geneNmList $refdir/$polList $joinAnnExtractDir $joinReportDir
	
	echo -e "\n  #--c--# Java Rapport Qual:"
	echo -e "\t  COMMAND: java -jar $autoAnnotdir/Rapport_QualPatient_CasavaGATK.jar $runFolder/ $numRunGa $numRunDiag $opGa $refdir/$targetsDiag $joinDir/QualityCASAVA.txt $joinDir/QualityGATK.txt $refdir/$geneNmList $joinAnnExtractDir $joinReportDir $TP53file $feuilleRouteFile"
	java -jar $autoAnnotdir/Rapport_QualPatient_CasavaGATK.jar $runFolder/ $numRunGa $numRunDiag $opGa $refdir/$targetsDiag $joinDir/QualityCASAVA.txt $joinDir/QualityGATK.txt $refdir/$geneNmList $joinAnnExtractDir $joinReportDir $TP53file $feuilleRouteFile
	
else
	echo -e "\nSKIP: #--5--# JOIN RAPPORT"
fi

#----------------------------------------------------------------------#
#--6--# GLOBAL QUALITY: 
if [ $doQualRun = "y" ]; 
then  
	echo -e "\n#--6--# GLOBAL QUALITY:"
	cd $variantsdir
	#chmod -R 777 $variantsdir
	echo -e "\t  COMMAND: $qualitydir/Quality.sh $refdir/$targets"
	$qualitydir/Quality.sh $refdir/$targets
	echo -e "\t  COMMAND: $qualitydir/OnOffTarget.sh $refdir/$targets"
	$qualitydir/OnOffTarget.sh $refdir/$targets
	mv $variantsdir/Summary_Quality.csv $joinDir/Summary_Quality.csv
	mv $variantsdir/Summary_OnOffTarget.csv $joinDir/Summary_OnOffTarget.csv

	#Additional Paired Stat (track mcf)
	tail -n +`grep -n "Additional Paired Statistics" $aligneddir/Project_*/Summary_Stats*/Barcode_Lane_Summary.htm | cut -f 1 -d":"` $aligneddir/Project_*/Summary_Stats*/Barcode_Lane_Summary.htm > $joinDir/CASAVA_AdditionalPairedStats.htm
else
	echo -e "\nSKIP: #--6--# GLOBAL QUALITY"
fi

date
echo -e "\n#----------------------------PIPELINE END------------------------------#";
		
#----------------------------------------------------------------------#
#----------------------------PIPELINE END------------------------------#
#----------------------------------------------------------------------#

