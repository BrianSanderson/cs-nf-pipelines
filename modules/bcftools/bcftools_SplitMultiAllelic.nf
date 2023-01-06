process BCF_SPLITMULTIALLELIC {
  tag "$sampleID"

  cpus = 1
  memory = 6.GB
  time = '06:00:00'

  container 'quay.io/biocontainers/bcftools:1.15--h0ea216a_2'

  input:
  tuple val(sampleID), file(vcf)

  output:
  tuple val(sampleID), file("*.vcf"), emit: vcf

  script:

  """
  bcftools \
  norm \
  -m \
  -any \
  --threads ${task.cpus} \
  --no-version \
  -f ${params.ref_genome} \
  -o ${sampleID}_split.vcf \
  ${vcf}
"""
}