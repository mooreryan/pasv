#!/usr/bin/env ruby

Signal.trap("PIPE", "EXIT")

require "optimist"

opts = Optimist.options do
  banner <<-EOS

  Example:

   ./to_html.rb --positions 100 50 --files `ls dir/*` > out.html

  Known issues:

    - The positions option highlights with respect to the columns of
      the alignment rather than the original residue.

  Options:
  EOS

  opt(:positions, "Key positions (1 based)", type: :integers)
  # opt(:start, "Spannig region start", type: :int, default: -1)
  # opt(:end, "Spannig region end", type: :int, default: -1)
  opt(:files, "Aln files", type: :strings)
end

unless opts[:files]
  abort "ERROR -- No files. Try -h"
end

html = %Q~
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

    <style type="text/css">

      body {
        font-family: sans-serif;
      }



      h2 {
        font-family: sans-serif;
      }

      .container {
        overflow: scroll;
        white-space: pre;
        font-family: monospace;
      }

      .sidebyside {
        //padding: 10px;
        display: inline-block;
      }

      .left {
       text-align: right;
width: 400px;
display: inline-block;
      }

      .right {
width: 1200px;
display: inline-block;
      }

      table, th, td {
        border: 2px solid black;
        border-collapse: collapse;
      }

      th, td {
        padding: 10px;
      }
    </style>

    <title>Trust the Process.</title>

  </head>

  <body>
%s
  </body>
</html>
~

# three format specs
aln_div = %Q~
<h2>%s</h2>
<div class="wrapper">
%s
%s
</div>
~

left = %Q~
<div class="sidebyside left container">
%s
</div>
~

right = %Q~
<div class="sidebyside right container">
%s
</div>
~

def round_down num
  rnum = num.round(-1)
  if rnum > num
    rnum -= 10
  end

  rnum
end

def steps last
  (10..last).step(10)
end

def make_step_str total_len
  last = round_down total_len

  the_steps = steps last

  str = "~" * total_len

  start_str = "Position"
  start_str.each_char.with_index do |char, idx|
    str[idx] = char
  end

  the_steps.each do |pos| # one based
    str_pos = pos.to_s
    len = str_pos.length

    (pos-1 .. pos-1+len).each_with_index do |n, idx|
      if idx.zero?
        str[n] = "|"
      else
        str[n] = str_pos[idx-1]
      end
    end
  end

  str
end


require "parse_fasta"

col = "background-color:rgba(17,186,138,0.15)"

divs = []
opts[:files].each do |fname|
  lstrings = []
  rstrings = []

  lengths = []
  ParseFasta::SeqFile.open(fname).each_record do |rec|
    lengths << rec.seq.length
    lstrings << rec.header

    this_len = rec.seq.length
    if opts[:positions]
      opts[:positions].each do |pos|
        if pos < 0 || pos > this_len
          abort "position #{pos} is out of bounds"
        end

        idx = pos - 1
        rec.seq[idx] = %Q{<span style="#{col}">#{rec.seq[idx]}</span>}
      end
    end

    rstrings << rec.seq

  end

  max_header_len = lstrings.map { |str| str.length }.max
  lstrings.map! { |str| sprintf("%#{max_header_len}s", str) }
  lstrings.unshift "Sequnce"

  max_seq_len = lengths.max

  rstrings.unshift make_step_str(max_seq_len)

  left_div = sprintf(left, lstrings.join("\n"))
  right_div = sprintf(right, rstrings.join("\n"))
  divs << sprintf(aln_div, fname, left_div, right_div);
end

printf html, divs.join("\n")
