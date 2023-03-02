def param_log(){
  log.info """
______________________________________________________

                AMPLICON PARAMETER LOG

--comment: ${params.comment}

Results Published to: ${params.pubdir}
______________________________________________________
--workflow                          ${params.workflow}
--gen_org                           ${params.gen_org}
--read_type                         ${params.read_type}
--sample_folder                     ${params.sample_folder}
--extension                         ${params.extension}
--pattern                           ${params.pattern}
--concat_lanes                      ${params.concat_lanes}
--csv_input                         ${params.csv_input}
--download_data                     ${params.download_data}
--organize_by                       ${params.organize_by}
--pubdir                            ${params.pubdir}
-w                                  ${workDir}
--keep_intermediate                 ${params.keep_intermediate}
-c                                  ${params.config}
--multiqc_config                    ${params.multiqc_config}
--xenome_prefix                     ${params.xenome_prefix}
--read_length                       ${params.read_length}
--star_index                        ${params.star_index}
--star_fusion_star_index            ${params.star_fusion_star_index}
--gtf                               ${params.gtf}
--fasta                             ${params.fasta}
--arriba_star_args                  ${params.arriba_star_args}
--arriba_blacklist                  ${params.arriba_blacklist}
--arriba_known_fusions              ${params.arriba_known_fusions}
--arriba_protein_domains            ${params.arriba_protein_domains}
--fusioncatcher_ref                 ${params.fusioncatcher_ref}
--fusioncatcher_limitSjdbInsertNsj  ${params.fusioncatcher_limitSjdbInsertNsj}
--jaffa_ref_dir                     ${params.jaffa_ref_dir}
--kallisto_index                    ${params.kallisto_index}
--transcript_fasta                  ${params.transcript_fasta}
--squid_star_args                   ${params.squid_star_args}
--star_fusion_ref                   ${params.star_fusion_ref}
--star_fusion_opt                   ${params.star_fusion_opt}
--fusion_report_opt                 ${params.fusion_report_opt}
--databases                         ${params.databases}
--pdx                               ${params.pdx}

Project Directory: ${projectDir}
______________________________________________________
"""

}
