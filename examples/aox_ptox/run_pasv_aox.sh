dir="$1"

refs="${dir}/refs_aox.fa.gz"
queries="${dir}/all.fa.gz"
threads=4
outdir="${dir}/pasv_output_aox"

date && time pasv \
  --refs ${refs} \
  --queries ${queries} \
  --aligner clustalo \
  --threads ${threads} \
  --outdir ${outdir} \
  233 234 235 236 237 238 239 \
  283 284 285 286 287
