Gem::Specification.new do |s|
  s.name = "latex_tagger"
  s.summary = "Scriptedly stamp e.g. a questionnaire number on a PDF with LaTeX"
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.md'))
  s.version = "0.3"
  s.author  = "Teoric"
  s.email = "code.teoric@gmail.com"
  s.homepage = "https://github.com/teoric/latex-stamp"
  s.requirements =
    [ 'a modern tex distribution with the LaTeX package pdfpages' ]
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.9'
  s.files = Dir['**/**']
  s.files.reject! do |fn|
    # STDERR.puts fn
    fn =~ /(?:\.(?:aux|log|bbl|blg|gem)|~)$/u or
    fn =~ /USED/ or
    fn =~ /PDFs/ or
    fn =~ /RAND/ or
    fn =~ /^(?:A|B|C)-/
  end
  s.executables = [
    'personalize.rb',
    'print_pdf.rb',
    'stamp-with-name.rb',
    'stamp-with-page.rb',
  ]
  s.test_files = Dir["test/test*.rb"]
  s.has_rdoc = false
end
