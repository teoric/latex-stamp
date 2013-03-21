This is a small package for 'tagging' PDF files. Tagging means either:

- processing a PDF file through LaTeX with `pdfpages` and stamping a
  number/identifier on it or
- processing a LaTeX file (e.g. of a cover sheet) and predefining a
  variable with a different number/identifier for each (e.g. for cover
  sheets).


The scripts were developed to stamp a random identifier on a bunch of
PDFs that were used in an experimental setting, so that different sheets
could be kept together easily and without losing anonymity. They are
placed here because I spent some time trying to find a simple solution.

- using
  [pdfpages](http://www.ctan.org/tex-archive/macros/latex/contrib/pdfpages)
  to 'stamp' the questionnaires (I found the hint on [Stack Exchange](http://tex.stackexchange.com), but mislaid it.
- using the LaTeX flag `-jobname` for generating 'nice' filenames,
- adding the original path to the LaTeX environment so that you can
  include macros etc. from there and do not have to call the scripts
  from there.


# Simple use

(If you just need a way of putting text on a PDF file, have a look at
the `example_template.tex`. This will be easier than using this script.)

The options are:

    Usage: ../bin/personalize [options]
        -p, --paperformat s              paper format (default: a4paper),
                                         as accepted by koma-script,
                                         e.g. a4paper, a5paper, letterpaper
        -T, --[no-]test                  only produce one sheet
            --groups g1,g2,g3            group prefices (at least one,
                                         default: A,B,C)
        -s, --size n                     size of groups (default: 12)
        -t, --template                   set LaTeX template from file


An example run is possible by going to the `examples` directory.
There is a shell wrapper that takes care to include the `lib` directory
in the path. (It should work on \*N\*X.)

    cd examples
    ../bin/personalize -T

By default, the script generates numbers between 1111 and 9999, and
outputs it in the lower right corner prefixed by `#` for the groups A, B
and C, i.e. e.g. `# A-7353`. If that is not what you want, you can
customize the LaTeX template, and of course the script, which is very
simple.

Files are read from a [YAML](http://yaml.org/) file called
`<GROUPNAME>.yaml` in the directory where the script is executed. It has
the form

    cover:
       - file1
       - file2
    sheet:
       - file3
       - file4

where `file3` and `file4` would use the stamped, and for `file1` and
`file2` a variable would be inserted.
Furthermore, a file `ALL.yaml` of the same format is read and processed
for all groups (whence follows: don't define an 'ALL' group ;-).)
(see `A.yaml` and `ALL.yaml`)

(If you need complicated modifications of the placement and page setup,
it is probably best to modify the LaTeX template; see
`example_template.tex`.)

You can also generate a ruby gem.


# Libraries

## LaTeX Tagger

`latex_tagger` contains the class `TeXTag`. 

    tt = TeXTag.new()
    tt = TeXTag.new(template:nil, paperformat:"a4paper")

sets up a LaTeX tagger with a default template for stamping. You can
also provide the `template` as a string. This template will be used to
'stamp' on PDF files. `paperformat` must be a class option passed to the
LaTeX document class of the template; the default template uses
[KOMA-Script](http://www.ctan.org/tex-archive/macros/latex/contrib/koma-script/),
and hence accepts `a4paper`, `letterpaper` and many more. (Hint for
hacks: the program does not check for the occurrence of commas.)

Now you have two methods:

    tt.tag_file(file, number, vars:nil, paperformat:nil)
    tt.cover_file(file, number, vars:nil)

`tag_file` expects a PDF file and stamps a number on it. `number` can be
any kind of string. It will be inserted in the `@template` wherever
`\tagnumber` (optionally with curly braces) occurs. (You can also use
`\filetotag`, which corresponds to the filename.) The value of
`number` is not escaped.

`tt.cover_file` expects a LaTeX file and just inserts a definition of
`\pdfnumber` and `\filetotag`, which you can then use in the TeX code.
(Have a look at `examples/cover.tex`.)

### Variables

You can also pass a variable hash of the form:

    vars = {
        :var_name => "value",
        :another_var_name => "buh!"
    }

Variable names are converted to TeX command names:

- the name is converted to a lower case ASCII 'slug' with [Babosa](https://github.com/norman/babosa), and transliterated according to German usage (i.e. `:Käsefüße` becomes `kaesefuesse`)
- anything but `[a-zA-Z]` is dropped

The value is not escaped and can contain LaTeX code. You are warned if
two variable names evaluate to the same TeX command (e.g. `käse123` and
`456kaese`).


**Note:** The variable handling is not safe, and you should not use this
in a way that you process someone else's variable values or templates.
(But this was obvious from the description, I assume.)


## Random Memory

`random_memory` contains the simple class `RandomMemory`, whose objects
provide non-repeating random numbers.

    rame = RandomMemory.new(exclude_numbers: Set.new, lower_limit:111, upper_limit:1000)

- `exclude_numbers`: an array/set of numbers that should not occur (=
  the memory)
- `lower_limit`: the lowest allowed random number
- `upper_limit`: the highest allowed random number

.

    rame.get_number  # get a random number
                     # raises RandomMemoryExceeded if all numbers have
                     # been used
                     # adds number to memory

    rame.reset       # reset memory : all numbers between `@lower_limit`
                     # and `@upper_limit` are allowed again

    rame.exclude (numbers)  # add numbers to memory (they will be
                            # excluded)
