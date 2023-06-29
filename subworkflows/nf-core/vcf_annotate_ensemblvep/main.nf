//
// Run VEP to annotate VCF files
//

include { ENSEMBLVEP_VEP } from '../../../modules/nf-core/ensemblvep/vep/main'
include { TABIX_TABIX    } from '../../../modules/nf-core/tabix/tabix/main'
include { VCF2MAF        } from '../../../modules/nf-core/vcf2maf/main'


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


    TABIX_TABIX(ENSEMBLVEP_VEP.out.vcf)

    ch_vcf_tbi = ENSEMBLVEP_VEP.out.vcf.join(TABIX_TABIX.out.tbi, failOnDuplicate: true, failOnMismatch: true)

    ch_vcf_dup = ch_vcf.duplicate()
    ch_vcf_dup.view()
    ch_fasta_dup = ch_fasta.duplicate()
    ch_fasta_dup.view()
    ch_cache_dup = ch_cache.duplicate()
    ch_cache_dup.view()    
    
    VCF2MAF(
        ch_vcf, 
        ch_fasta, 
        ch_cache
    )

    // Gather versions of all tools used
    ch_versions = ch_versions.mix(ENSEMBLVEP_VEP.out.versions)
    ch_versions = ch_versions.mix(TABIX_TABIX.out.versions)
    ch_versions = ch_versions.mix(VCF2MAF.out.versions)

    emit:
    vcf_tbi  = ch_vcf_tbi
    json     = ENSEMBLVEP_VEP.out.json
    tab      = ENSEMBLVEP_VEP.out.tab
    reports  = ENSEMBLVEP_VEP.out.report
    maf      = VCF2MAF.out.maf
    versions = ch_versions
}
