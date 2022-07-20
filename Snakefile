# File Name: Snakefile
# Created By: HKim
# Created On: 2022-07-19
# Purpose: Runs the scRNA-Seq analysis Pipeline


# Module Imports
# ----------------------------------------------------------------------------
from gardnersnake.core import Configuration
from operator import itemgetter

# Function Defintions
# ----------------------------------------------------------------------------
get_run_id = itemgetter("run_id")

def get_fastqs_dir(runs, run_id):
    pass

# Global Configuration
# ----------------------------------------------------------------------------
cfg = Configuration("config/scRNA-Seq-template.yaml")
cfg.load()

GLOBS = cfg.global_params
RULES = cfg.rule_params

RUNS = 


# Rule 0. Align and Quantify from FASTQ.
# ---------------------------------------------------------------------------

cr_rp = RULES.CR_fastq_to_counts
rule CR_fastq_to_counts:
    input: ### what if input != output from prev func
        transcriptome = GLOBS.files.transcriptome,
        fastq = get_fastqs_dir(runs=GLOBS.files.sequencing, run_id="{wildcards.run}")
    output:
        rc = "CR_fastq_to_counts.rc.out"
    params: **(cr_rp.parameters)
    # TODO: lambda wildcards: wildcards.sample
    resources: **(cr_rp.resources)
    envmodules:
        "gcc/6.2.0",
        "cellranger/6.1.2"
    shell:
        """
        cellranger count --id= {params.run_id}\
                        --transcriptome={input.transcriptome} \
                        --fastqs={input.fastq} \
                        --sample={params.samples} \
                        --include-introns \
                        --expect-cells={params.ncells} \
                        --localcores={resources.processors_per_node} \
                        --localmem={resources.total_memory_gb} \
        && check_directory -o {output.rc} {params.checkfiles} {params.alignment_directory}
    	"""
