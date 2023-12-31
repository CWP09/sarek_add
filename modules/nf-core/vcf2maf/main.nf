process VCF2MAF {

    tag "$meta.id"
    label 'process_low'

    conda "bioconda::vcf2maf=1.6.21 bioconda::ensembl-vep=109.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-b6fc09bed47d0dc4d8384ce9e04af5806f2cc91b:305092c6f8420acd17377d2cc8b96e1c3ccb7d26-0':
        'biocontainers/mulled-v2-b6fc09bed47d0dc4d8384ce9e04af5806f2cc91b:305092c6f8420acd17377d2cc8b96e1c3ccb7d26-0' }"

    input:
    tuple val(meta), path(vcf)
    path fasta
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
    if command -v vep &> /dev/null
   then
       VEP_CMD="--vep-path /data/chaewon/anaconda3/envs/ensembl-vep-109/bin"
       VEP_VERSION=\$(echo -e "\\n    ensemblvep: \$( echo \$(vep --help 2>&1) | sed 's/^.*Versions:.*ensembl-vep : //;s/ .*\$//')")
   else
       VEP_CMD="--vep-path /data/chaewon/anaconda3/envs/ensembl-vep-109/bin"
       VEP_VERSION=""
   fi

    bgzip -c -d ${vcf} > ${prefix}.vcf

    /data/chaewon/anaconda3/envs/ensembl-vep-109/bin/vcf2maf.pl \\
        $args \\
        \$VEP_CMD \\
        $vep_cache_cmd \\
        --ref-fasta $fasta \\
        --input-vcf ${prefix}.vcf \\
        --output-maf ${prefix}.maf

    echo "${task.process}:" > versions.yml
    echo "    vcf2maf: $VERSION\$VEP_VERSION" >> versions.yml
    """
}
