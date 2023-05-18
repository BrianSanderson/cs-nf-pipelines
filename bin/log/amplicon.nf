import Logos

logo = new Logo()
println '\n'
println logo.show()

def param_log(){
log.info """
AMPLICON PARAMETER LOG

--comment: ${params.comment}

Results Published to: ${params.pubdir}
______________________________________________________
--workflow                      ${params.workflow}

WORKFLOW NOT OFFICALLY SUPPORTED AT THIS TIME. 

  // Shared params
  gen_org = 'human'
  extension='.fastq.gz'
  pattern="*_R{1,2}*"
  read_type = 'PE' // SE
  sample_folder = null
  concat_lanes = false
  download_data = false
  csv_input = null

  multiqc_config = "${projectDir}/bin/shared/multiqc/amplicon_multiqc.yaml"

  cutadaptMinLength  = 20
  cutadaptQualCutoff = 20
  cutadaptAdapterR1  = 'CTGTCTCTTATACACATCTCCGAGCCCACGAGAC'
  cutadaptAdapterR2  = 'CTGTCTCTTATACACATCTGACGCTGCCGACGA'


  ref_fa = '/projects/omics_share/human/GRCh38/genome/sequence/gatk/Homo_sapiens_assembly38.fasta'
  ref_fa_indices = '/projects/omics_share/human/GRCh38/genome/indices/gatk/bwa/Homo_sapiens_assembly38.fasta'
  mismatch_penalty = "-B 8"

  masterfile = '/projects/compsci/omics_share/human/GRCh38/supporting_files/capture_kit_files/IDT/xGen_sampleID_amplicon/hg38Lifted_xGen_masterfile.txt'

  amplicon_primer_intervals = '/projects/compsci/omics_share/human/GRCh38/supporting_files/capture_kit_files/IDT/xGen_sampleID_amplicon/hg38Lifted_xGen_SampleID_primers.interval_list'
  amplicon_target_intervals = '/projects/compsci/omics_share/human/GRCh38/supporting_files/capture_kit_files/IDT/xGen_sampleID_amplicon/hg38Lifted_xGen_SampleID_merged_targets.interval_list'

  gold_std_indels = '/projects/omics_share/human/GRCh38/genome/annotation/snps_indels/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz'
  phase1_1000G = '/projects/omics_share/human/GRCh38/genome/annotation/snps_indels/1000G_phase1.snps.high_confidence.hg38.vcf.gz'
  dbSNP = '/projects/omics_share/human/GRCh38/genome/annotation/snps_indels/dbsnp_151.vcf.gz'

  ploidy_val = '-ploidy 2' // variable in haplotypecaller. not required for amplicon, but present in module. 
  target_gatk = '/projects/compsci/omics_share/human/GRCh38/supporting_files/capture_kit_files/IDT/xGen_sampleID_amplicon/hg38Lifted_xGen_SampleID_merged_targets.bed' 
  params.call_val = "50.0"

  dbSNP = '/projects/omics_share/human/GRCh38/genome/annotation/snps_indels/dbsnp_151.vcf.gz'
  dbSNP_index = '/projects/omics_share/human/GRCh38/genome/annotation/snps_indels/dbsnp_151.vcf.gz.tbi'

  tmpdir = "/fastscratch/${USER}" 
  bwa_min_score = null



Project Directory: ${projectDir}

Command line call: 
${workflow.commandLine}
______________________________________________________
"""

}
