# File Name: Snakefile
# Created By: HKim
# Created On: 2022-07-19
# Purpose: Runs the scRNA-Seq analysis Pipeline


# Module Imports
# ----------------------------------------------------------------------------
from gardnersnake.core import Configuration
from pathlib import Path


# Global Configuration
# ----------------------------------------------------------------------------
yaml_config_filepath = Path(config["yaml_config"])
cfg = Configuration(filepath=yaml_config_filepath)
cfg.load()

GLOBALS = cfg.global_params

# build a map of the sequencing data
SEQ = GLOBALS.files.sequencing
RUN_IDS = [s["run_id"] for s in SEQ]  # get the run ids for each sequencing obj
SEQ_MAP = {run_id:idx for idx,run_id in enumerate(RUN_IDS)}  # get their index 


# Function Definitions
# ----------------------------------------------------------------------------
get_fastq_dir = lambda run_id: SEQ[SEQ_MAP[run_id]]["fastq_dir"] 


# Rule 0. Pipeline Global Returns
# ----------------------------------------------------------------------------
rule All:
    input: 
        expand("cellranger_counts.{run_id}.rc.out", run_id=RUN_IDS)
        

# Rule 1. Align and Quantify from FASTQ.
# ---------------------------------------------------------------------------

cellranger_rp = cfg.get_rule_params(rulename="CellRanger_FASTQ_to_counts")

rule CellRanger_FASTQ_to_counts:
    input:
        transcriptome = GLOBALS.files.transcriptome,
        fastq_dir = lambda wildcards: get_fastq_dir(run_id=f"{wildcards.run_id}")
    output: cellranger_counts_rc = "cellranger_counts.{run_id}.rc.out"
    params: **(cellranger_rp.parameters), sample = lambda wildcards: f"{wildcards.run_id}"
    resources: **(cellranger_rp.resources)
    envmodules: *(cellranger_rp.parameters.envmodules)
    shell:
        "cellranger count --id= {params.sample}"
        " --transcriptome={input.transcriptome}"
        " --fastqs={input.fastq_dir}"
        " --sample={params.sample}"
        " --expect-cells={params.ncells}"
        " --localcores={resources.processors_per_node}"
        " --localmem={resources.total_memory_gb}"
        " {params.extra_args}"
        " && check_directory -o {output.cellranger_counts_rc}"
        " {params.checkfiles} {params.sample}/outs/"


