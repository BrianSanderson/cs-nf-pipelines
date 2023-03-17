process PICARD_FIX_MATE_INFORMATION {
  tag "$sampleID"

  cpus = 1
  memory { bam.size() < 60.GB ? 6.GB : 24.GB }
  time { bam.size() < 60.GB ? '03:00:00' : '12:00:00' }

  container 'quay.io/biocontainers/picard:2.26.10--hdfd78af_0'
  publishDir "${params.pubdir}/${ params.organize_by=='sample' ? sampleID : 'picard' }", pattern: "*fixed_mate.bam", mode:'copy', enabled: params.keep_intermediate

  input:
  tuple val(sampleID), file(bam)

  output:
  tuple val(sampleID), file("*_fixed_mate.bam"), emit: fixed_mate_bam

  script:

  String my_mem = (task.memory-1.GB).toString()
  my_mem =  my_mem[0..-4]

  """
  picard -Xmx${my_mem}G FixMateInformation \
  I=${bam} \
  O=${sampleID}_fixed_mate.bam \
  ADD_MATE_CIGAR=true
  """
}
