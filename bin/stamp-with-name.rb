#!/usr/bin/env ruby
# encoding: utf-8

# Stamp files with name

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

STAMPED = "stamped"
Dir.mkdir(STAMPED) unless Dir.exists?(STAMPED)


ARGV.each do |file|
  tag = File.basename(file, ".pdf")
  job = stamp.tag_file(file, tag, clean: true)
  system("lpr", "-PEiF",
    "-o", "Duplex=DuplexTumble",
    "-o", "number-up=2",
    "-o", "StpiShrinkOutput=Crop",
    "#{job}.pdf")
  File.rename("#{job}.pdf", File.join(STAMPED, file))
end
