rule stats:
    input:
        bam="results/mapped/{sample}.bam",
        bai="results/mapped/{sample}.bam.bai"
    output:
        "results/stats/{sample}.txt"
    conda:
        "../envs/samtools_env.yaml"
    log:
        "results/logs/mapping_stats/{sample}.log"
    shell:
        "samtools idxstats {input.bam} > {output} 2> {log}"

rule filter:
    input:
        bam="results/mapped/{sample}.bam",
        bai="results/mapped/{sample}.bam.bai"
    output:
        "results/filtered/{sample}_filtered.bam"
    conda:
        "../envs/samtools_env.yaml"
    log: 
        "results/logs/filter/{sample}.log"
    shell:
        "samtools view -b {input.bam} NK_AMKI01000040.1 NK_AMKI01000041.1 > {output} 2> {log}"

rule sort:
    input:
        "results/mapped/{sample}.bam"
    output:
        "results/bam_sorted/{sample}_sorted.bam"
    conda:
        "../envs/samtools_env.yaml"
    log: 
        "results/logs/sort_bam/{sample}.log"
    shell:
        "samtools sort {input} -o {output} 2> {log}"

rule index:
    input:
        rules.sort.output
    output:
        "results/bam_sorted/{sample}_sorted.bam.bai"
    conda:
        "../envs/samtools_env.yaml"
    log: 
        "results/logs/index_bam/{sample}.log"
    shell:
        "samtools index {input} {output} 2> {log}"

#get .fasta consensus from each mapped read .bam file
#incomplete
rule consensus
    input
        rules.sort.output
        rules.index.ouput
    output
        "results/mapped_consensus/{sample}_mapped_consensus.fa"
    conda
    log
    shell

#concatenate 
#incomplete
rul concat
    input
        lambda wc: "results/mapped_consensus/{wc.sample}_mapped_consensus.fa"
    output
    conda
    log
    shell
    "cat {input} > {output}"

#output from concatenate should go into mafft
