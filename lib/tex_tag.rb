class TeXTag
    require "babosa"
    @tex_template = <<'EOF'
\documentclass[\paperformat,12pt]{scrartcl}
\usepackage[left=40mm,right=1.5cm, top=1cm, bottom=3cm]{geometry}
\usepackage{sourcecodepro}
\usepackage{fancyhdr}
\usepackage{pdfpages}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\rfoot{\Large\texttt{\# \tagnumber}}

\begin{document}

\includepdf[pages=1-,pagecommand={\thispagestyle{fancy}}]{\filetotag}


\end{document}

EOF
# \rfoot{\thepage}

  class << self
  attr_reader :tex_template
  end

  attr_reader :tex_template

  class VarHash
    class TeXVarError < StandardError
    end

    def initialize(variables)
      @vars = {}
      variables.each do |k,v|
        k = k.to_s
        var = k.to_slug.normalize(transliterations: :german).to_ascii.to_s.gsub(/[^a-zA-Z]/,"")
        if @vars.keys.index var
          raise TeXVarError, "Variable «#{var}» (from: «#{k}») used twice!"
        elsif var =~ /^(?:paperformat|filetotag|tagnumber)/
          raise TeXVarError, "Variable «#{var}» is used by LaTeXTagger itself!"
        else
          @vars[var] = v
        end
      end
    end

    def serialize
      ret = ""
      @vars.each do |var, val|
        ret << ('\def\%s{%s}' % [var, val])
        ret << "\n"
      end
      ret
    end
  end


  def initialize (template:nil, paperformat:"a4paper")
    if template
      @tex_template = template
    else
      @tex_template = self.class.tex_template
    end
    @paperformat = paperformat
  end

  def include_filepath(file)
    # add directory of file to tex's input directories so that includes
    # work
    # TODO: use environent hash with popen instead?
    evars = %w[TEXINPUTS BSTINPUTS BIBINPUTS]
    old_vars = {}
    evars.each do |v|
      old_vars[v] = ENV[v]
      ENV[v] = File.dirname(file) + ":" + ENV[v]
    end
    yield
    evars.each do |v|
      ENV[v] = old_vars[v]
    end
  end

  private
  def process_file(file, number, type="pdf")
    include_filepath(file) do
      file_root = File.basename(file, type="."+type.to_s)
      job = "%s-%s" % [number, file_root]
      IO.popen(["pdflatex", "-jobname", job ], mode="w") do |tex|
        yield tex
      end
    end
  end

  public
  def tag_file(file, number, vars:nil, paperformat:nil)
    # tag file with number
    process_file(file, number, type="pdf") do |tex|
      tex.write("\\def\\tagnumber{#{number}}")
      tex.write("\\\def\\filetotag{#{file}}")
      if vars
        tex.puts VarHash.new(vars).serialize
      end
      paperformat ||= @paperformat
      tex.puts @tex_template.gsub(/\\paperformat(?:\b|\{\})/, paperformat)
      tex.puts '\end'
    end
  end

  def cover_file(file, number, vars:nil)
    # generate cover with number from LaTeX template
    File.open(file,"r") do |f|
      process_file(file, number, type=:tex) do |tex|
        tex.puts("\\def\\tagnumber{#{number}}")
        tex.puts("\\def\\filetotag{#{file}}")
        if vars
          tex.puts VarHash.new(vars).serialize
        end
        tex.puts (f.read)
        tex.puts '\end'
      end
    end
  end

end
