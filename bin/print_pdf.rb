#!/usr/bin/env ruby
# encoding: utf-8

# Stamp files with name if containing directory

$LOAD_PATH.unshift File.join(File.dirname(File.dirname(File.realdirpath(__FILE__))), "lib")

tex_template = <<'EOF'
\documentclass[\paperformat,12pt]{scrartcl}
\usepackage[left=40mm,right=1.5cm, top=2cm, bottom=3cm]{geometry}
\usepackage{sourcecodepro}
\usepackage{fancyhdr}
\usepackage{pdfpages}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\rhead{\texttt{\# \tagnumber}}

\begin{document}

\includepdf[pages=1-,
  noautoscale, scale= .95,
  pagecommand={\thispagestyle{fancy}}]{\filetotag}


\end{document}

EOF


require "tex_tag"
stamp = TeXTag.new(template: tex_template)

name = File.basename Dir.pwd #=> "Attachments"

ARGV.each do |file|
  new_file = file.gsub(/\s/,"-")
  new_file.gsub!(/[,;:!?]/, "-")
  new_file.gsub!(/\.(?!pdf)/, "-")
  if file != new_file
    File.rename(file, new_file)
    file = new_file
  end
  job = stamp.tag_file(file, name, clean: true)
  system("lpr", "-PLJ1320_PCL",
    "-o", "Duplex=DuplexTumble",
    "-o", "number-up=2",
    "-o", "StpiShrinkOutput=Crop",
    "#{job}.pdf")
  File.unlink("#{job}.pdf")
end
