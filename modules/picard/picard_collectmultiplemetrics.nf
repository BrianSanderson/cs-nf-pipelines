process PICARD_COLLECTMULTIPLEMETRICS {
  tag "$sampleID"

  cpus = 1
  memory = 6.GB
  time = '03:00:00'

  container 'quay.io/biocontainers/picard:2.26.10--hdfd78af_0'

  publishDir "${params.pubdir}/${ params.organize_by=='sample' ? sampleID+'/stats' : 'picard' }", pattern: "*.CollectMultipleMetrics.*", mode:'copy'

  input:
  tuple val(sampleID), file(bam)

  output:
  tuple val(sampleID), file("*.CollectMultipleMetrics.*")

  script:
  log.info "----- Picard CollectMultipleMetrics Running on: ${sampleID} -----"
  prefix = "${sampleID}.mLb.clN"
  String my_mem = (task.memory-1.GB).toString()
  my_mem =  my_mem[0..-4]

  """
  picard -Xmx${my_mem}G CollectMultipleMetrics \
  INPUT=${bam[0]} \
  OUTPUT=${prefix}.CollectMultipleMetrics \
  REFERENCE_SEQUENCE=${params.ref_fa} \
  VALIDATION_STRINGENCY=LENIENT 
  TMP_DIR=${params.tmpdir} 
  """
}
