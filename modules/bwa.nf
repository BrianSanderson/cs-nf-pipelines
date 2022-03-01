process BWA_MEM {
  tag "sampleID"

  cpus 8
  memory 60.GB
  time '30:00:00'
  clusterOptions '-q batch'
// add retry once with strategy: +=60gb and +=30H

  container 'quay.io/biocontainers/bwa:0.7.17--h5bf99c6_8'	// breaks when updated: issue with readgroup

  publishDir "${params.pubdir}/${ params.organize_by=='sample' ? sampleID : 'bwa_mem' }", pattern: "*.sam", mode:'copy', enabled: params.keep_intermediate

  input:
  tuple val(sampleID), file(fq_reads)
  tuple val(sampleID), file(read_groups)

  output:
  tuple val(sampleID), file("*.sam"), emit: sam

  script:
  log.info "----- BWA-MEM Alignment Running on: ${sampleID} -----"

  if (params.read_type == "SE"){
    inputfq="${fq_reads[0]}"
    }
  if (params.read_type == "PE"){
    inputfq="${fq_reads[0]} ${fq_reads[1]}"
    }

  """
  rg=\$(cat $read_groups)
  bwa mem -M -R \${rg} \
  -t $task.cpus ${params.ref_fa} $inputfq > ${sampleID}.sam
  """
  }
