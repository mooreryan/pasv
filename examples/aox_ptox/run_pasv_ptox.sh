dir="$1"

refs="${dir}/refs_ptox.fa.gz"
queries="${dir}/all.fa.gz"
threads=4
outdir="${dir}/pasv_output_ptox"

date && time pasv \
  --refs ${refs} \
  --queries ${queries} \
  --aligner clustalo \
  --threads ${threads} \
  --outdir ${outdir} \
  157 158 160 161 \
  177 178 179 180 182 183
