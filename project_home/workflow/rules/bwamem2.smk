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
        "results/logs/bwamem2/bwamem2_FMindex.log"
    params:
        algtype = config["bwamem2"]["algtype"]
    shell:
        "bwa index -p {input} -a {params.algtype}"

rule alignReads:
    input:
        rules.constructFMindex.output
        ref = ref
        fq1 = "results/trimmed/{sample}_1_trimmed.fastq", 
        fq2 = "results/trimmed/{sample}_2_trimmed.fastq",  
    output:
        bam = "results/aligned/{sample}.bam",
        bai = "results/aligned/{sample}.bam.bai"
    conda:
        "../envs/bwamem2_env.yaml"
    threads: 4 
    log: 
        "results/logs/bwamem2/{sample}_align.log"
    shell:
        """
        bwa-mem2 mem \
            -t {threads} \
            {input.ref} \
            {input.fq1} \
            {input.fq2} \
        2> {log}
        """