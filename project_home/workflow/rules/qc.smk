rule rawFastQC_R1:
    input: 
        lambda wc: fq1_dict[wc.sample]
    output:
        html="results/quality_control/raw/{sample}_1_fastqc.html",
        zip="results/quality_control/raw/{sample}_1_fastqc.zip"
    log: 
        "results/logs/rawFastQC/{sample}_R1.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

rule rawFastQC_R2:
    input: 
        lambda wc: fq2_dict[wc.sample]
    output:
        html="results/quality_control/raw/{sample}_2_fastqc.html",
        zip="results/quality_control/raw/{sample}_2_fastqc.zip"
    log: 
        "results/logs/rawFastQC/{sample}_R2.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

rule processReads:
    input:
        fq1 = lambda wc: fq1_dict[wc.sample],
        fq2 = lambda wc: fq2_dict[wc.sample]
    output:
        out1="results/trimmed/{sample}_1_trimmed.fastq.gz",
        out2="results/trimmed/{sample}_2_trimmed.fastq.gz",
        unpaired1="results/trimmed/{sample}_1_unpaired_trimmed.fastq.gz",
        unpaired2="results/trimmed/{sample}_2_unpaired_trimmed.fastq.gz"
    conda:
        "../envs/qc_env.yaml"
    log:
        "results/logs/fastp/{sample}.log"
    threads: 4
    shell:
        """
        fastp \
        -i {input.fq1} -I {input.fq2} \
        -o {output.out1} -O {output.out2} \
        --unpaired1 {output.unpaired1} \
        --unpaired2 {output.unpaired2} \
        --thread {threads} \
        2> {log} 
        """

rule processedFastQC_R1:
    input: 
        "results/trimmed/{sample}_1_trimmed.fastq.gz"
    output:
        html="results/quality_control/trimmed/{sample}_1_trimmed_fastqc.html",
        zip="results/quality_control/trimmed/{sample}_1_trimmed_fastqc.zip"
    log: 
        "results/logs/trimmedFastQC/{sample}_R1.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

rule processedFastQC_R2:
    input: 
        "results/trimmed/{sample}_2_trimmed.fastq.gz"
    output:
        html="results/quality_control/trimmed/{sample}_2_trimmed_fastqc.html",
        zip="results/quality_control/trimmed/{sample}_2_trimmed_fastqc.zip"
    log: 
        "results/logs/trimmedFastQC/{sample}_R2.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

rule qualimapStats:
    input:
        "results/sorted/{sample}_sorted.bam"
    output:
        directory("results/quality_control/qualimapStats/{sample}_qualimap_stats")
    conda:
        "../envs/qc_env.yaml"
    log:
        "results/logs/qualimapStats/{sample}.log"
    shell:
        """
        qualimap bamqc -bam {input} \
        -outdir {output} \
        -pe 2> {log}
        """

rule aggregateQC:
    input:
        expand(
            "results/quality_control/raw/{sample}_1_fastqc.zip",
            sample=SAMPLES
        ),
        expand(
            "results/quality_control/raw/{sample}_2_fastqc.zip",
            sample=SAMPLES
        ),
        expand(
            "results/quality_control/trimmed/{sample}_1_trimmed_fastqc.zip",
            sample=SAMPLES
        ),
        expand(
            "results/quality_control/trimmed/{sample}_2_trimmed_fastqc.zip",
            sample=SAMPLES
        )
    output: 
        "results/quality_control/aggregated/quality_control_aggregated.html"
    log:
        "results/logs/aggregateQC/aggregateQC.log"
    threads: 1
    conda: 
        "../envs/qc_env.yaml"
    shell:
        "multiqc results/quality_control -o results/quality_control/aggregated -n quality_control_aggregated 2> {log}"
