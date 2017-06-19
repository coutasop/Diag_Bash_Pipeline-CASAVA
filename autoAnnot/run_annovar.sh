#!/bin/bash
#
# Juliette AURY-LANDAS & Sophie COUTANT
# 11/07/2013
#
#------------------------------------------------------------------------------------------------------------------------------------------------------------#
# This script allows the automation of variants annotation using the ANNOVAR tool                                                                            #
# Wang K, Li M, Hakonarson H. ANNOVAR: Functional annotation of genetic variants from next-generation sequencing data, Nucleic Acids Research, 38:e164, 2010 #
#                                                                                                                                                            #
# 1- convert variant calling file (output of CASAVA, Samtools or GATK) to ANNOVAR input file                                                                 #
#    -> tab separated file: chromosome, start position, end position, reference nucleotides, observed nucleotides (+ other free optional columns)            #
# 2- variant annotation by ANNOVAR                                                                                                                           #
#------------------------------------------------------------------------------------------------------------------------------------------------------------#

# usage
function usage
{
    echo "USAGE: run_annovar.sh -a <directory> -i <directory> -o <directory>"
    echo "		 -a <annovar source directory>"
    echo "		 -i <input directory containing variant calling files (vcf)>"
    echo "		 -o <output directory for the annotated files>"
    echo "EXAMPLE: ./run_annovar.sh -a /home/me/Program/Annovar -i Project/VCF -o Project/Annotated"
}

# get the arguments of the command line
if [ $# -lt 6 ]; then
	usage
	exit
else
	while [ "$1" != "" ]; do
	    case $1 in
		-a | --annovar )         shift
					if [ "$1" != "" ]; then
						# Annovar scripts path
						annovarPath=$1
					else
						usage
						exit
					fi
		                        ;;
		                        
		-i | --iDirectory )    	shift
					if [ "$1" != "" ]; then
						inputDirectory=$1
					else
						usage
						exit
					fi
		                        ;;
		                        
		                        
		-o | --oDirectory )    	shift
					if [ "$1" != "" ]; then
						outputDirectory=$1
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

#Test if the output directory exists, if no, create it
if [ -d $outputDirectory ]; then
 echo -e "\n\tOUTPUT FOLDER: $outputDirectory (folder already exist)" 
else
 mkdir $outputDirectory 
 echo -e "\n\tOUTPUT FOLDER : $outputDirectory (folder created)"
fi


#format des fichiers vcf en input
fileExt=".vcf"

# initialisation des variables
chr=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y)

echo -e "\t TIME: BEGIN ANNOVAR ANNOTATION".`date`
for vcFile in `ls $inputDirectory/*$fileExt`; do #pour chaque fichier de variant calling contenu dans le répertoire
	fileName=${vcFile%.*} #nom du fichier sans sa dernière extension (ici: .vcf)
	sample=$(basename $fileName) #nom du fichier sans path et sans extention
	path=$(dirname $fileName) #nom du path, sans le fichier
	
	nbCol=$(tail -n 1 $vcFile | wc -w);
	if [ $nbCol != 10 ]; then
		fileFormat="vcf4old"	#multivcf File
	else
		fileFormat="vcf4"		#vcf with 1 sample
	fi
	echo -e "\n\t#FILE: $vcFile:"
	
	#------------------------------------------------------------------------------------------------------------------------------------------------------------#
	# 1- CONVERSION du fichier de variant calling (sortie de Casava, Samtools ou GATK) en fichier d'entrée d'Annovar
		# -includeinfo 		// all information in the input line should be included in the output line
		
	echo -e "\t1- CONVERSION IN ANNOVAR INPUT"
	#conversion d'un fichier vcf de CASAVA/SamTools/GATK (1 fichier /exome)
		# -allallele 		// Multi-allelic calls
	
	#DON'T USE -allallele WITH THE NEW VERSION OF ANNOVAR
	#~ echo -e "\t#CMD: $annovarPath/convert2annovar.pl -format $fileFormat -allallele -includeinfo $vcFile > $fileName.avinput"
	#~ $annovarPath/convert2annovar.pl -format $fileFormat -allallele -includeinfo $vcFile > $fileName.avinput
	echo -e "\t#CMD: $annovarPath/convert2annovar.pl -format $fileFormat -includeinfo $vcFile > $fileName.avinput"
	$annovarPath/convert2annovar.pl -format $fileFormat -includeinfo $vcFile > $fileName.avinput



	#------------------------------------------------------------------------------------------------------------------------------------------------------------#
	# 2- ANNOTATIONS des variants par Annovar
	
	#INPUT
		# -buildver		// genome build version (hg19)
		# -protocol		// annotations to run
			# refGene		// RefSeq transcript annotations (refGene, refLink, refMrna).
			# ljb2_all		// whole-exome SIFT scores, PolyPhen2 HDIV scores, PolyPhen2 HVAR scores, LRT scores, MutationTaster scores, MutationAssessor score, FATHMM scores, GERP++ scores, PhyloP scores and SiPhy scores. Scores were retrieved from the dbNSFP (http://sites.google.com/site/jpopgen/dbNSFP).
			# cosmic64		// COSMIC database version 64 (previously observed cancer mutations, their identifiers in COSMIC, How many times are observed, and in which cancer tissues are observed). Including non-coding variants.
			# esp6500si_ea		// alternative allele frequency in European Americans in the NHLBI-ESP project with 6500 exomes, Including the indel calls and the chrY calls.
			# esp6500si_all		// ... in all subjects.
			# 1000g2012apr_eur	// alternative allele frequency data in 1000 Genomes Project for european populations.
			# 1000g2012apr_all	// ... for all populations.
			# snp137		// dbSNP with ANNOVAR index files 
			# snp137NonFlagged	// dbSNP with ANNOVAR index files, after removing those flagged SNPs (SNPs < 1% minor allele frequency (MAF) (or unknown), Mapping only once to reference assembly, flagged in dbSnp as "clinically associated")
			# cytoBand		// the approximate location of bands seen on Giemsa-stained chromosomes
			# wgRna			// snoRNA and miRNA annotations
		# -operation		// type of annotations (g:gene-based, f:filter-based, r:region-based)
		# -otherinfo		// all information in the input line should be included in the output line
	
	#OUTPUT
		# file.hg19_multianno.txt	// variant calling file containing all annotations
		# file.log			// annotation log
	
	echo -e "\t2- ANNOTATION WITH ANNOVAR"
	#Two COMMAND
	
	#-1 WITH EVS AND 1000Genome MAF
#OLD 2013 command	#~ echo -e "\t#CMD: $annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,ljb2_all,cosmic64,esp6500si_ea,esp6500si_all,1000g2012apr_eur,1000g2012apr_all,snp137,snp137NonFlagged,cytoBand,wgRna -operation g,f,f,f,f,f,f,f,f,r,r -otherinfo -outfile $outputDirectory/$sample"
#OLD 2013 command	#~ $annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,ljb2_all,esp6500si_ea,esp6500si_all,1000g2012apr_eur,1000g2012apr_all,snp137,snp137NonFlagged,wgRna -operation g,f,f,f,f,f,f,f,r -nastring . -argument '-hgvs -exonicsplicing -splicing_threshold 50',,,,,,,, -otherinfo -outfile $outputDirectory/$sample

#OLD	echo -e "\t#CMD: $annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,ljb26_all,esp6500si_ea,esp6500si_all,1000g2014oct_eur,1000g2014oct_all,exac02,snp138,snp138NonFlagged,wgRna -operation g,f,f,f,f,f,f,f,f,f,r,r -otherinfo -outfile $outputDirectory/$sample"
#OLD	$annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,ljb26_all,esp6500si_ea,esp6500si_all,1000g2014oct_eur,1000g2014oct_all,exac02,snp138,snp138NonFlagged,wgRna -operation g,f,f,f,f,f,f,f,f,r -nastring . -argument '-hgvs -exonicsplicing -splicing_threshold 50',,,,,,,,, -otherinfo -outfile $outputDirectory/$sample

	echo -e "\t#CMD: $annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,popfreq_max_20150413,exac03,esp6500siv2_ea,esp6500siv2_all,1000g2015aug_eur,1000g2015aug_all,snp138,snp138NonFlagged,ljb26_all,wgRna -operation g,f,f,f,f,f,f,f,f,f,r -argument '-hgvs -otherinfo -splicing_threshold 2','-otherinfo',,,,,,,,, -nastring . -otherinfo -outfile $outputDirectory/$sample"
	$annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,popfreq_max_20150413,exac03,esp6500siv2_ea,esp6500siv2_all,1000g2015aug_eur,1000g2015aug_all,snp138,snp138NonFlagged,ljb26_all,wgRna -operation g,f,f,f,f,f,f,f,f,f,r -argument '-hgvs -otherinfo -splicing_threshold 2','-otherinfo',,,,,,,,, -nastring . -otherinfo -outfile $outputDirectory/$sample
	
	
	#-2 OR WITHOUT MAF (Faster)
	#~ echo -e "\t#CMD: $annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,ljb2_all -operation g,f -nastring . -argument '-hgvs -exonicsplicing -splicing_threshold 50', -otherinfo -outfile $outputDirectory/$sample"
	#~ $annovarPath/table_annovar.pl $fileName.avinput $annovarPath/humandb/ -buildver hg19 -protocol refGene,ljb2_all -operation g,f -nastring . -argument '-hgvs -exonicsplicing -splicing_threshold 50', -otherinfo -outfile $outputDirectory/$sample

	#suppression du fichier d'entrée dans annovar
	#rm $fileName.avinput
	
	#suppression des fichiers intermédiaires créés par table_annovar.pl
	rm $outputDirectory/$sample.log
	rm $outputDirectory/$sample.refGene.exonic_variant_function
	rm $outputDirectory/$sample.refGene.invalid_input
	rm $outputDirectory/$sample.refGene.log
	rm $outputDirectory/$sample.refGene.variant_function
	rm $outputDirectory/$sample.hg19_ljb26_all_dropped
	rm $outputDirectory/$sample.hg19_ljb26_all_filtered
	
	#~ rm $outputDirectory/$sample.hg19_cosmic64_dropped
	#~ rm $outputDirectory/$sample.hg19_cosmic64_filtered
	rm $outputDirectory/$sample.hg19_esp6500si_ea_dropped
	rm $outputDirectory/$sample.hg19_esp6500si_ea_filtered
	rm $outputDirectory/$sample.hg19_esp6500si_all_dropped
	rm $outputDirectory/$sample.hg19_esp6500si_all_filtered
	rm $outputDirectory/$sample.hg19_EUR.sites.2014_09_dropped
	rm $outputDirectory/$sample.hg19_EUR.sites.2014_09_filtered
	rm $outputDirectory/$sample.hg19_ALL.sites.2014_09_dropped
	rm $outputDirectory/$sample.hg19_ALL.sites.2014_09_filtered
	rm $outputDirectory/$sample.hg19_snp138_dropped
	rm $outputDirectory/$sample.hg19_snp138_filtered
	rm $outputDirectory/$sample.hg19_snp138NonFlagged_dropped
	rm $outputDirectory/$sample.hg19_snp138NonFlagged_filtered
	#~ rm $outputDirectory/$sample.hg19_cytoBand
	rm $outputDirectory/$sample.hg19_wgRna
	#~ rm $outputDirectory/$sample.invalid_input #invalid input from the variant calling file => NOT annotated but present in the multianno.txt output file

	echo -e "\t#DONE - #Output $outputDirectory/$sample.hg19_multianno.txt"
done
echo -e "\t TIME: END ANNOVAR ANNOTATION".`date`
