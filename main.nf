#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// import workflow of interest
if (params.workflow == "rnaseq"){
  include {RNASEQ} from './workflows/rnaseq'
}
else if (params.workflow == "wes"){
  include {WES} from './workflows/wes'
}
else if (params.workflow == "wgs"){
  include {WGS} from './workflows/wgs'
}
else if (params.workflow == "rrbs"){
  include {RRBS} from './workflows/rrbs'
}
else if (params.workflow == "atac"){
  include {ATAC} from './workflows/atac'
}
else if (params.workflow == "pta"){
  include {PTA} from './workflows/pta'
} 
else {
  // if workflow name is not supported: 
  exit 1, "ERROR: No valid pipeline called. '--workflow ${params.workflow}' is not a valid workflow name."
}

// conditional to kick off appropriate workflow
workflow{
  if (params.workflow == "rnaseq"){
    RNASEQ()
    }
  if (params.workflow == "wes"){
    WES()
    }
  if (params.workflow == "wgs"){
    WGS()
    }
  if (params.workflow == "rrbs"){
    RRBS()
    }
  if (params.workflow == "atac"){
    ATAC()
    }
  if (params.workflow == "pta"){
    PTA()
  } 
}
