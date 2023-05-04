process HOMER_ANNOTATEPEAKS {
    tag "${run_tag}"
    
    cpus 2
    memory 10.GB
    time '10:00:00'

    publishDir "${params.pubdir}/${ params.organize_by=='sample' ? 'immuno_precip_samples/antibody_'+antibody+'/macs2' : 'macs2' }", pattern: "*annotatePeaks.txt", mode: 'copy'

    container 'quay.io/biocontainers/homer:4.11--pl526hc9558a2_3'

    input:
    tuple val(antibody), val(replicatesExist), val(multipleGroups), val(ip), val(control), file(peak)
    file(fasta)
    file(gtf)

    output:
    tuple val(ip), path("*annotatePeaks.txt"), emit: txt


    script:
    prefix = peak =~ /bed/ ?  "${antibody}.consensus_peaks" : "${ip}_peaks"
    run_tag = ip ? "${ip} vs ${control}" : "${antibody}"

    """
    annotatePeaks.pl \\
        $peak \\
        $fasta \\
        -gid \\
        -gtf $gtf \\
        -cpu $task.cpus \\
        > ${prefix}.annotatePeaks.txt
    """
}
