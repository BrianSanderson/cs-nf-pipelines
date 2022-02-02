#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// import modules
include {BWA_MEM} from '../modules/bwa'
include {CAT_HUMAN;
         CAT_HUMAN as CAT_HUMAN_0} from '../bin/wes/cat'
include {QUALITY_STATISTICS} from '../modules/quality_stats'
include {READ_GROUPS} from '../modules/read_groups'
include {PICARD_SORTSAM;
         PICARD_MARKDUPLICATES;
         PICARD_COLLECTHSMETRICS} from '../modules/picard'
include {SAMTOOLS_INDEX} from '../modules/samtools'
include {SNPEFF;
         SNPEFF_HUMAN;
         SNPEFF_HUMAN as SNPEFF_HUMAN_0} from '../modules/snpeff'
include {SNPSIFT_EXTRACTFIELDS;
         SNPSIFT_EXTRACTFIELDS as SNPSIFT_EXTRACTFIELDS_0;
         SNPSIFT_DBNSFP;
         SNPSIFT_DBNSFP as SNPSIFT_DBNSFP_0} from '../modules/snpsift'
include {AGGREGATE_STATS_MOUSE;AGGREGATE_STATS_HUMAN} from '../bin/wes/aggregate_stats'
include {COSMIC_ANNOTATION;
         COSMIC_ANNOTATION as COSMIC_ANNOTATION_0} from '../modules/cosmic'
// many from gatk
include {GATK_HAPLOTYPECALLER;
         GATK_HAPLOTYPECALLER as GATK_HAPLOTYPECALLER_GVCF;
         GATK_INDEXFEATUREFILE;
         GATK_INDEXFEATUREFILE as GATK_INDEXFEATUREFILE_0;
         GATK_VARIANTFILTRATION;
         GATK_VARIANTFILTRATION as GATK_VARIANTFILTRATION_0;
         GATK_VARIANTANNOTATOR;
         GATK_MERGEVCF;
         GATK_SELECTVARIANTS;GATK_SELECTVARIANTS as GATK_SELECTVARIANTS_0;
         GATK_BASERECALIBRATOR;
         GATK_APPLYBQSR} from '../modules/gatk'

// prepare reads channel
if (params.read_type == 'PE'){
  read_ch = Channel.fromFilePairs("${params.fq_path}/*_R{1,2}_*${params.extension}",checkExists:true )
}
else if (params.read_type == 'SE'){
  read_ch = Channel.fromFilePairs("${params.fq_path}/*${params.extension}",checkExists:true, size:1 )
}

// main workflow
workflow WES {
  // Step 1: Qual_Stat
  QUALITY_STATISTICS(read_ch) 
  // Step 2: Get Read Group Information
  READ_GROUPS(QUALITY_STATISTICS.out.trimmed_fastq)
  // Step 3: BWA-MEM Alignment
  BWA_MEM(QUALITY_STATISTICS.out.trimmed_fastq, READ_GROUPS.out.read_groups )  
  // Step 4: Variant Preprocessing - Part 1
  PICARD_SORTSAM(BWA_MEM.out.bwa_mem)
  PICARD_MARKDUPLICATES(PICARD_SORTSAM.out.picard_sortsam_bam) 
  
  // If Human: Step 5-11
  if (params.gen_org=='human'){

    // Step 5: Variant Pre-Processing - Part 2
      GATK_BASERECALIBRATOR(PICARD_MARKDUPLICATES.out.dedup_bam)
      GATK_APPLYBQSR(PICARD_MARKDUPLICATES.out.dedup_bam, 
                     GATK_BASERECALIBRATOR.out.table)

    // Step 6: Variant Pre-Processing - Part 3
      PICARD_COLLECTHSMETRICS(GATK_APPLYBQSR.out.bam,
                              GATK_APPLYBQSR.out.bai)

    // Step 7: Variant Calling
      GATK_HAPLOTYPECALLER(GATK_APPLYBQSR.out.bam,
                           GATK_APPLYBQSR.out.bai,
                          'varient')
      GATK_HAPLOTYPECALLER_GVCF(GATK_APPLYBQSR.out.bam,
                                GATK_APPLYBQSR.out.bai,
                                'gvcf')

    // Step 8: Variant Filtration
      // SNP
        GATK_SELECTVARIANTS(GATK_HAPLOTYPECALLER.out.vcf,
                            GATK_HAPLOTYPECALLER.out.idx,
                           'SNP')
        GATK_VARIANTFILTRATION(GATK_SELECTVARIANTS.out.vcf,
                               GATK_SELECTVARIANTS.out.idx,
                              'SNP')

      // INDEL
      	GATK_SELECTVARIANTS_0(GATK_HAPLOTYPECALLER.out.vcf, 
                              GATK_HAPLOTYPECALLER.out.idx,
                             'INDEL')
        GATK_VARIANTFILTRATION_0(GATK_SELECTVARIANTS_0.out.vcf,
                                 GATK_SELECTVARIANTS_0.out.idx,
                                'INDEL')

    // Step 9: Post Variant Calling Processing - Part 1
      // SNP
        COSMIC_ANNOTATION(GATK_VARIANTFILTRATION.out.vcf)
        SNPEFF_HUMAN(COSMIC_ANNOTATION.out.vcf, 'SNP')
        SNPSIFT_DBNSFP(SNPEFF_HUMAN.out.vcf, 'SNP')
        CAT_HUMAN(SNPSIFT_DBNSFP.out.vcf, 'SNP')
        SNPSIFT_EXTRACTFIELDS(CAT_HUMAN.out.vcf)

      // INDEL
	COSMIC_ANNOTATION_0(GATK_VARIANTFILTRATION_0.out.vcf)
        SNPEFF_HUMAN_0(COSMIC_ANNOTATION_0.out.vcf, 'INDEL')
        SNPSIFT_DBNSFP_0(SNPEFF_HUMAN_0.out.vcf, 'INDEL')
        CAT_HUMAN_0(SNPSIFT_DBNSFP_0.out.vcf, 'INDEL')
        SNPSIFT_EXTRACTFIELDS_0(CAT_HUMAN_0.out.vcf)

    // Step 10: Post Variant Calling Processing - Part 2
      GATK_MERGEVCF(CAT_HUMAN.out.vcf,
                    CAT_HUMAN_0.out.vcf)

    // Step 11: Aggregate Stats
      AGGREGATE_STATS_HUMAN(QUALITY_STATISTICS.out.quality_stats,
                            PICARD_COLLECTHSMETRICS.out.hsmetrics,
                            PICARD_MARKDUPLICATES.out.dedup_metrics)  
  }           

  else if (params.gen_org=='mouse'){

    // Step 6: Variant Pre-Processing - Part 3
      PICARD_COLLECTHSMETRICS(PICARD_MARKDUPLICATES.out.dedup_bam,
                              PICARD_MARKDUPLICATES.out.dedup_bai)

    // Step 7: Variant Calling
      GATK_HAPLOTYPECALLER(PICARD_MARKDUPLICATES.out.dedup_bam,
                           PICARD_MARKDUPLICATES.out.dedup_bai,
                          'varient')

    // Step 8: Variant Filtration
      GATK_INDEXFEATUREFILE(GATK_SELECTVARIANTS.out.vcf)
      GATK_VARIANTFILTRATION(GATK_HAPLOTYPECALLER.out.vcf,
                             GATK_INDEXFEATUREFILE.out.idx,
                            'INDEL')

    // Step 9: Post Variant Calling Processing - Part 1 (just renaming--skip for now) 
    // CAT_SNP_INDEL()

    // Step 10: Post Variant Calling Processing - Part 2 (this all needs updating -- the containers and versions are wicked old)
      SNPEFF(GATK_VARIANTFILTRATION.out.vcf)
      GATK_VARIANTANNOTATOR(GATK_VARIANTFILTRATION.out.vcf,
                            SNPEFF.out.vcf)
      SNPSIFT_EXTRACTFIELDS(GATK_VARIANTFILTRATION.out.vcf)

    // Step 11: Aggregate Stats (UNIQUE TO BIN/WES)
      AGGREGATE_STATS_MOUSE(QUALITY_STATISTICS.out.quality_stats,
                            PICARD_COLLECTHSMETRICS.out.hsmetrics)
  }

}
