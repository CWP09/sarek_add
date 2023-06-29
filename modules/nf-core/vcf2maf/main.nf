process VCF2MAF {

    tag "$meta.id"
    label 'process_low'

    conda "bioconda::vcf2maf=1.6.21 bioconda::ensembl-vep=106.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-b6fc09bed47d0dc4d8384ce9e04af5806f2cc91b:305092c6f8420acd17377d2cc8b96e1c3ccb7d26-0':
        'biocontainers/mulled-v2-b6fc09bed47d0dc4d8384ce9e04af5806f2cc91b:305092c6f8420acd17377d2cc8b96e1c3ccb7d26-0' }"

    input:
    tuple val(meta), path(vcf)
    tuple val(meta2), path(fasta)
    path cache

    output:
    tuple val(meta), path("*.maf"), emit: maf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args          = task.ext.args   ?: ''
    def prefix        = task.ext.prefix ?: "${meta.id}"
    def vep_cache_cmd = cache       ? "--vep-data $cache" : ""
    def VERSION = '1.6.21'

    """
    bgzip -c -d ${vcf} > ${prefix}.vcf

    vcf2maf.pl \\
        $args \\
        \$VEP_CMD \\
        $vep_cache_cmd \\
        --ref-fasta /data/chaewon/ref/GRCh38/Homo_sapiens_assembly38.fasta \\
        --input-vcf ${prefix}.vcf \\
        --output-maf ${prefix}.maf

    echo "${task.process}:" > versions.yml
    echo "    vcf2maf: $VERSION\$VEP_VERSION" >> versions.yml
    """
}
