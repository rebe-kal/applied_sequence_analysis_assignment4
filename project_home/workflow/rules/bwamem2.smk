ref = config["ref"]

rule constructFMindex:
    input:
        ref
    output:
        amb = "results/FMindex/reference.amb",
        ann = "results/FMindex/reference.ann",
        bwt = "results/FMindex/reference.bwt.2bit.64",
        pac = "results/FMindex/reference.pac",
        sa = "results/FMindex/reference.sa"
    conda:
        "../envs/bwamem2_env.yaml"
    threads: 4
    log:
        "results/logs/FMindex/bwamem2_FMindex.log"
    params:
        algtype = config["bwamem2"]["algtype"]
    shell:
        "bwa index -p {input} -a {params.algtype}"

rule mapReads:
    input:
        rules.constructFMindex.output,
        ref = ref,
        fq1 = "results/trimmed/{sample}_1_trimmed.fastq.gz", 
        fq2 = "results/trimmed/{sample}_2_trimmed.fastq.gz",  
    output:
        bam = "results/mapped/{sample}.bam",
        bai = "results/mapped/{sample}.bam.bai"
    conda:
        "../envs/bwamem2_env.yaml"
    threads: 4 
    log: 
        "results/logs/mapping/{sample}_mapped.log"
    shell:
        """
        bwa-mem2 mem \
            -t {threads} \
            {input.ref} \
            {input.fq1} \
            {input.fq2} \
        2> {log}
        """
