//
// Run PROKKA on contigs that are split by size, then concatenate output and gunzip it
//

include { PROKKA               } from '../../modules/nf-core/prokka/main'
include { CAT_CAT as GFF_CAT   } from '../../modules/nf-core/cat/cat/main'
include { CAT_CAT as FAA_CAT   } from '../../modules/nf-core/cat/cat/main'
include { CAT_CAT as FNA_CAT   } from '../../modules/nf-core/cat/cat/main'

workflow PROKKA_CAT {
    take:
        contigs // channel: [ val(meta), file(contigs) ]

    main:
        ch_versions = Channel.empty()

        PROKKA  (contigs.splitFasta(size: 10.MB, file: true).map { contigs -> [[id: contigs.getBaseName()], contigs] }, [], [] )
        ch_versions = ch_versions.mix(PROKKA.out.versions)
        GFF_CAT (PROKKA.out.gff.collect{it[1]}.map { [ [ id: 'prokka'], it ] })
        FAA_CAT (PROKKA.out.faa.collect{it[1]}.map { [ [ id: 'prokka'], it ] })
        FNA_CAT (PROKKA.out.fna.collect{it[1]}.map { [ [ id: 'prokka'], it ] })
        ch_versions = ch_versions.mix(FNA_CAT.out.versions)

    emit:
        gff      = GFF_CAT.out.file_out
        faa      = FAA_CAT.out.file_out
        fna      = FNA_CAT.out.file_out

        versions = ch_versions

}
