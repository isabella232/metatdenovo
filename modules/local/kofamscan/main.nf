process KOFAMSCAN_SCAN {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::kofamscan=1.3.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kofamscan:1.3.0--hdfd78af_2':
        'quay.io/biocontainers/kofamscan:1.3.0--hdfd78af_2' }"

    input:
    tuple val(meta), path(fastaprot)
    tuple val(kodb), path(ko_list), path(famscan)

    output:
    tuple val(meta), path("kofamscan_output.tsv.gz"), emit: kout
    path "versions.yml"                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    exec_annotation \\
        --profile $famscan \\
        --ko-list $ko_list \\
        --format detail-tsv \\
        --tmp-dir tmp_kofamscan \\
        $fastaprot \\
        -o kofamscan_output.tsv

    gzip kofamscan_output.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kofamscan: \$(echo \$(exec_annotation --version 2>&1) | sed 's/^.*exec_annotation//' )
    END_VERSIONS
    """
}
