#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// import modules
include {CHECK_DESIGN} from '../modules/utility_modules/chipseq_check_design'
include {SAMTOOLS_FAIDX} from '../modules/samtools/samtools_faidx'
include {MAKE_GENOME_FILTER} from '../modules/utility_modules/chipseq_make_genome_filter'
include {FASTQC} from '../modules/fastqc/fastqc'
include {TRIM_GALORE} from '../modules/trim_galore/trim_galore'
include {READ_GROUPS} from '../modules/utility_modules/read_groups'
include {BWA_MEM} from '../modules/bwa/bwa_mem'
include {SAMTOOLS_FILTER} from '../modules/samtools/samtools_filter'
include {SORT;
         SORT as PAIR_SORT;
         SORT as NAME_SORT} from '../modules/samtools/samtools_sort'
include {SAMTOOLS_STATS;
         SAMTOOLS_STATS as SAMTOOLS_STATS_MD;
         SAMTOOLS_STATS as SAMTOOLS_STATS_PE;
         SAMTOOLS_STATS as SAMTOOLS_STATS_BF} from '../modules/samtools/samtools_stats'
include {PICARD_MERGESAMFILES} from '../modules/picard/picard_mergesamfiles'
include {PICARD_MARKDUPLICATES} from '../modules/picard/picard_markduplicates'
include {SAMTOOLS_MERGEBAM_FILTER} from '../modules/samtools/samtools_mergebam_filter'
include {BAMTOOLS_FILTER} from '../modules/bamtools/bamtools_filter'
include {BAMPE_RM_ORPHAN} from '../modules/utility_modules/chipseq_bampe_rm_orphan'
include {PRESEQ} from '../modules/preseq/preseq'
include {PICARD_COLLECTMULTIPLEMETRICS} from '../modules/picard/picard_collectmultiplemetrics'
include {BEDTOOLS_GENOMECOV} from '../modules/bedtools/bedtools_genomecov'
include {UCSC_BEDGRAPHTOBIGWIG} from '../modules/ucsc/ucsc_bedgraphtobigwig'
include {DEEPTOOLS_COMPUTEMATRIX} from '../modules/deeptools/deeptools_computematrix'
include {DEEPTOOLS_PLOTPROFILE} from '../modules/deeptools/deeptools_plotprofile'
include {DEEPTOOLS_PLOTHEATMAP} from '../modules/deeptools/deeptools_plotheatmap'
include {PHANTOMPEAKQUALTOOLS} from '../modules/phantompeakqualtools/phantompeakqualtools'
include {MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS} from '../modules/multiqc/multiqc_custom_phantompeakqualtools'
include {DEEPTOOLS_PLOTFINGERPRINT} from '../modules/deeptools/deeptools_plotfingerprint'
include {PEAK_CALLING_CHIPSEQ} from '../modules/macs2/macs2_peak_calling_chipseq'
include {FRIP_SCORE} from '../modules/utility_modules/frip_score'
include {HOMER_ANNOTATEPEAKS } from '../modules/homer/homer_annotatepeaks'



// main workflow
workflow CHIPSEQ {

  if (params.input)     { ch_input = file(params.input, checkIfExists: true) } else { exit 1, 'Samples design file not specified!' }

  // Step 1: CHECK_DESIGN
  CHECK_DESIGN(ch_input)

  /*
  * Create channels for input fastq files
  */

  if (params.read_type == 'SE'){
      read_ch = CHECK_DESIGN.out[0]
                   .splitCsv(header:true, sep:',')
                   .map { row -> [ row.sample_id, [ file(row.fastq_1, checkIfExists: true) ] ] }
  } else {
      read_ch = CHECK_DESIGN.out[0]
                   .splitCsv(header:true, sep:',')
                   .map { row -> [ row.sample_id, [ file(row.fastq_1, checkIfExists: true), file(row.fastq_2, checkIfExists: true) ] ] }
  }

  /*
   * Create a channel with [sample_id, control id, antibody, replicatesExist, multipleGroups]
   */
  control_ch = CHECK_DESIGN.out[1]
      .splitCsv(header:true, sep:',')
      .map { row -> [ row.sample_id, row.control_id, row.antibody, row.replicatesExist.toBoolean(), row.multipleGroups.toBoolean() ] }


  // Header files for MultiQC
  ch_spp_nsc_header           = file("/projects/compsci/vmp/slek/ref/assets/multiqc/spp_nsc_header.txt", checkIfExists: true)
  ch_spp_rsc_header           = file("/projects/compsci/vmp/slek/ref/assets/multiqc/spp_rsc_header.txt", checkIfExists: true)
  ch_spp_correlation_header   = file("/projects/compsci/vmp/slek/ref/assets/multiqc/spp_correlation_header.txt", checkIfExists: true)
  ch_peak_count_header        = file("/projects/compsci/vmp/slek/ref/assets/multiqc/peak_count_header.txt", checkIfExists: true)
  ch_frip_score_header        = file("/projects/compsci/vmp/slek/ref/assets/multiqc/frip_score_header.txt", checkIfExists: true)
  ch_peak_annotation_header   = file("/projects/compsci/vmp/slek/ref/assets/multiqc/peak_annotation_header.txt", checkIfExists: true)
  ch_deseq2_pca_header        = file("/projects/compsci/vmp/slek/ref/assets/multiqc/deseq2_pca_header.txt", checkIfExists: true)
  ch_deseq2_clustering_header = file("/projects/compsci/vmp/slek/ref/assets/multiqc/deseq2_clustering_header.txt", checkIfExists: true)


  // Reference genome
  ch_fasta = file(params.fasta, checkIfExists: true)
  ch_gtf   = file(params.gtf, checkIfExists: true)

  // genes.bed
  if (params.gene_bed)  { ch_gene_bed = file(params.gene_bed, checkIfExists: true) }

  // Step 2: Make genome filter
  SAMTOOLS_FAIDX(ch_fasta)
  MAKE_GENOME_FILTER(SAMTOOLS_FAIDX.out, params.blacklist)

  // Step 3: Fastqc
  FASTQC(read_ch)
  
  // Step 4: Trim Galore
  TRIM_GALORE(read_ch)

  // Step 5: Get Read Group Information
  READ_GROUPS(TRIM_GALORE.out.trimmed_fastq, "gatk")

  // Step 6: BWA-MEM
  bwa_mem_mapping = TRIM_GALORE.out.trimmed_fastq.join(READ_GROUPS.out.read_groups)
  BWA_MEM(bwa_mem_mapping)

  // Step 7: Samtools Removing Unmapped
  SAMTOOLS_FILTER(BWA_MEM.out, '-F 0x0100')

  // Step 8: Samtools Sort
  // cannot use emit as -n (sampleID sort) option is incompatible with samtools index. 
  SORT(SAMTOOLS_FILTER.out.bam, '')

  // Step 9: Samtools Stats
  SAMTOOLS_STATS(SORT.out[0])


  // Step 10: Merge BAM files
  ch_sort_bam_merge = SORT.out

  // Merge BAM files for all libraries from same sample replicate
  ch_sort_bam_merge
    .map { it -> [ it[0].split('_')[0..-2].join('_'), it[1] ] }
    .groupTuple(by: [0])
    .map { it ->  [ it[0], it[1].flatten() ] }
    .set { ch_sort_bam_merge }

  // ch_sort_bam_merge = [sampleID, [bam, index]]
  PICARD_MERGESAMFILES(ch_sort_bam_merge)


  // Step 11: Mark Duplicates
  PICARD_MARKDUPLICATES(PICARD_MERGESAMFILES.out.bam)

  // Step 12: Samtools Stats
  SAMTOOLS_STATS_MD(PICARD_MARKDUPLICATES.out.dedup_bam)

  // Step 13: Samtools Mergebam Filter
  SAMTOOLS_MERGEBAM_FILTER(PICARD_MARKDUPLICATES.out.dedup_bam, MAKE_GENOME_FILTER.out[0])

  // JSON files required by BAMTools for alignment filtering
  if (params.read_type == 'SE'){
    ch_bamtools_filter_config = file(params.bamtools_filter_se_config, checkIfExists: true)
  } else {
    ch_bamtools_filter_config = file(params.bamtools_filter_pe_config, checkIfExists: true)
  }

  // Step 14: Bamtools Filter
  BAMTOOLS_FILTER(SAMTOOLS_MERGEBAM_FILTER.out.bam, ch_bamtools_filter_config) 

  // Step 15: Samtools Stats
  SAMTOOLS_STATS_BF(BAMTOOLS_FILTER.out.bam)

  // Step 16: Samtools Name Sort
  NAME_SORT(BAMTOOLS_FILTER.out.bam, '-n ')

  // Step 17: Remove singleton reads from paired-end BAM file
  BAMPE_RM_ORPHAN(NAME_SORT.out[0])

  // Step 18 : Samtools Pair Sort
  PAIR_SORT(BAMPE_RM_ORPHAN.out.bam, '')

  // Step 19 : Samtools Stats
  SAMTOOLS_STATS_PE(PAIR_SORT.out[0])

  // Step 20 : Preseq
  PRESEQ(PICARD_MARKDUPLICATES.out.dedup_bam)

  // Step 21 : Collect Multiple Metrics
  PICARD_COLLECTMULTIPLEMETRICS(PAIR_SORT.out)  

  // Step 22 : Bedtools Genome Coverage
  BEDTOOLS_GENOMECOV(PAIR_SORT.out, SAMTOOLS_STATS_PE.out[0])

  // Step 23 : USCS Bedgraph to bigwig
  UCSC_BEDGRAPHTOBIGWIG(BEDTOOLS_GENOMECOV.out.bedgraph, MAKE_GENOME_FILTER.out[1])

  // Step 24 : Deeptools Compute matrix
  DEEPTOOLS_COMPUTEMATRIX(UCSC_BEDGRAPHTOBIGWIG.out.bigwig, ch_gene_bed)

  // Step 25 : Deeptools Plot Profile
  DEEPTOOLS_PLOTPROFILE(DEEPTOOLS_COMPUTEMATRIX.out.matrix)

  // Step 26 : Deeptools Plot Heatmap
  DEEPTOOLS_PLOTHEATMAP(DEEPTOOLS_COMPUTEMATRIX.out.matrix)

  // Step 27 : Phantompeakqualtools
  PHANTOMPEAKQUALTOOLS(BAMPE_RM_ORPHAN.out.bam)

  // Step 28 : Multiqc Custom Phantompeakqualtools
  mcp_ch = PHANTOMPEAKQUALTOOLS.out.spp.join(PHANTOMPEAKQUALTOOLS.out.rdata, by: [0])
  MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS(mcp_ch, ch_spp_nsc_header, ch_spp_rsc_header, ch_spp_correlation_header)


  // Create channel linking IP bams with control bams  
  ch_genome_bam_bai = PAIR_SORT.out

  ch_genome_bam_bai
        .combine(ch_genome_bam_bai)
        .set { ch_genome_bam_bai }

  ch_group_bam = control_ch
                    .combine(ch_genome_bam_bai )
                    .filter { it[0] == it[5] && it[1] == it[7] }
                    .join(SAMTOOLS_STATS_PE.out[0])
                    .map { it ->  it[2..-1] }

  // Step 29 : Deeptools plotFingerprint
  DEEPTOOLS_PLOTFINGERPRINT(ch_group_bam) 

  // Step 30 : Call peaks with MACS2 
  PEAK_CALLING_CHIPSEQ(ch_group_bam, ch_peak_count_header, ch_frip_score_header)

  // Step 31 : Calculate FRiP score
  FRIP_SCORE(ch_group_bam, PEAK_CALLING_CHIPSEQ.out.peak, ch_peak_count_header, ch_frip_score_header)

  // Step 32 : Homer Annotate Peaks
  HOMER_ANNOTATEPEAKS(PEAK_CALLING_CHIPSEQ.out.ip_control_peak, ch_fasta, ch_gtf)



}
