def param_log(){
if (params.gen_org=='human')
  log.info """
______________________________________________________

                CHIPSEQ PARAMETER LOG

--comment: ${params.comment}

Results Published to: ${params.pubdir}
______________________________________________________
--workflow                      ${params.workflow}
--gen_org                       ${params.gen_org}
--read_type                     ${params.read_type}
--input                         ${params.input}
--pattern                       ${params.pattern}
--extension                     ${params.extension}
-w                              ${workDir}
-c                              ${params.config}
--pubdir                        ${params.pubdir}
--organize_by                   ${params.organize_by}
--fragment_size                 ${params.fragment_size}
--fingerprint_bins              ${params.fingerprint_bins}
--gtf                           ${params.gtf}
--gene_bed                      ${params.gene_bed}
--ref_fa                        ${params.ref_fa}
--ref_fa_indices                ${params.ref_fa_indices}
--macs_gsize                    ${params.macs_gsize}
--blacklist                     ${params.blacklist}
--non_directional      		      ${params.non_directional}
--trimLength           		      ${params.trimLength}
--qualThreshold        		      ${params.qualThreshold}
--adapOverlap                   ${params.adapOverlap}
--adaptorSeq                    ${params.adaptorSeq}
--mismatch_penalty              ${params.mismatch_penalty}
--bwa_min_score                 ${params.bwa_min_score}
--keep_dups                     ${params.keep_dups}
--keep_multi_map                ${params.keep_multi_map}
--bamtools_filter_pe_config     ${params.bamtools_filter_pe_config} 
--bamtools_filter_se_config     ${params.bamtools_filter_se_config} 
--narrow_peak                   ${params.narrow_peak}
--broad_cutoff                  ${params.broad_cutoff}
--skip_preseq                   ${params.skip_preseq}
--skip_peak_qc                  ${params.skip_peak_qc}
--skip_peak_annotation          ${params.skip_peak_annotation}
--skip_consensus_peaks          ${params.skip_consensus_peaks}
--skip_diff_analysis            ${params.skip_diff_analysis}
--deseq2_vst                    ${params.deseq2_vst}
--macs_fdr                      ${params.macs_fdr}
--macs_pvalue                   ${params.macs_pvalue}
--min_reps_consensus            ${params.min_reps_consensus}
--save_macs_pileup              ${params.save_macs_pileup}
--tmpdir                        ${params.tmpdir}

Project Directory: ${projectDir}
______________________________________________________
"""
else
log.info """
______________________________________________________

                CHIPSEQ PARAMETER LOG

--comment: ${params.comment}

Results Published to: ${params.pubdir}
______________________________________________________
--workflow                      ${params.workflow}
--gen_org                       ${params.gen_org}
--read_type                     ${params.read_type}
--input                         ${params.input}
--pattern                       ${params.pattern}
--extension                     ${params.extension}
-w                              ${workDir}
-c                              ${params.config}
--pubdir                        ${params.pubdir}
--organize_by                   ${params.organize_by}
--fragment_size                 ${params.fragment_size}
--fingerprint_bins              ${params.fingerprint_bins}
--gtf                           ${params.gtf}
--gene_bed                      ${params.gene_bed}
--ref_fa                        ${params.ref_fa}
--ref_fa_indices                ${params.ref_fa_indices}
--macs_gsize                    ${params.macs_gsize}
--blacklist                     ${params.blacklist}
--non_directional               ${params.non_directional}
--trimLength                    ${params.trimLength}
--qualThreshold                 ${params.qualThreshold}
--adapOverlap                   ${params.adapOverlap}
--adaptorSeq                    ${params.adaptorSeq}
--mismatch_penalty              ${params.mismatch_penalty}
--bwa_min_score                 ${params.bwa_min_score}
--keep_dups                     ${params.keep_dups}
--keep_multi_map                ${params.keep_multi_map}
--bamtools_filter_pe_config     ${params.bamtools_filter_pe_config}
--bamtools_filter_se_config     ${params.bamtools_filter_se_config}
--narrow_peak                   ${params.narrow_peak}
--broad_cutoff                  ${params.broad_cutoff}
--skip_preseq                   ${params.skip_preseq}
--skip_peak_qc                  ${params.skip_peak_qc}
--skip_peak_annotation          ${params.skip_peak_annotation}
--skip_consensus_peaks          ${params.skip_consensus_peaks}
--skip_diff_analysis            ${params.skip_diff_analysis}
--deseq2_vst                    ${params.deseq2_vst}
--macs_fdr                      ${params.macs_fdr}
--macs_pvalue                   ${params.macs_pvalue}
--min_reps_consensus            ${params.min_reps_consensus}
--save_macs_pileup              ${params.save_macs_pileup}

Project Directory: ${projectDir}
______________________________________________________
"""

}
