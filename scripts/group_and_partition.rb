#!/usr/bin/env ruby

Signal.trap("PIPE", "EXIT")

if ARGV.count < 8
  abort "USAGE: #{__FILE__} bin_dir threads num_iters refs.fa queries.fa " +
        "start end pos1 pos2 ... posN"
end

bin, threads, num_iters, refs, queries, start, stop, *posns = ARGV

split =     "#{bin}/split_seqs"
group =     "#{bin}/group_seqs"
partition = "#{bin}/partition_seqs"

cmd = "#{split} #{threads} #{queries}"
puts cmd
`#{cmd}`

cmd = %Q{parallel --jobs #{threads} "#{group} #{num_iters} #{refs} {} #{start} #{stop} #{posns.join(" ")}" ::: #{queries}.split_*}
puts cmd
`#{cmd}`

cmd = "#{partition} #{queries} #{queries}.split_*.seq_groups"
puts cmd
`#{cmd}`
