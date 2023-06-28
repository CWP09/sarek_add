//
// Run VEP to annotate VCF files
//

include { ENSEMBLVEP_VEP } from '../../../modules/nf-core/ensemblvep/vep/main'
include { VCF2MAF } from '../../../modules/nf-core/vcf2maf/main.nf'



workflow VCF_ANNOTATE_ENSEMBLVEP {
    take:
    ch_vcf
    ch_fasta
    val_genome
    val_species
    val_cache_version
    ch_cache
    ch_extra_files

    main:
    ch_versions = Channel.empty()

    ENSEMBLVEP_VEP(
        ch_vcf,
        val_genome,
        val_species,
        val_cache_version,
        ch_cache,
        ch_fasta,
        ch_extra_files
    )

    
    ch_vcf_vep = ENSEMBLVEP_VEP.out.vcf

     VCF2MAF(
        ch_vcf_vep,
        ch_fasta,
        ch_cache
    )


    // Gather versions of all tools used
    ch_versions = ch_versions.mix(ENSEMBLVEP_VEP.out.versions)
    ch_versions = ch_versions.mix(VCF2MAF.out.versions)

    emit:
    json     = ENSEMBLVEP_VEP.out.json
    tab      = ENSEMBLVEP_VEP.out.tab
    reports  = ENSEMBLVEP_VEP.out.report
    maf      = VCF2MAF.out.maf
    versions = ch_versions
}
