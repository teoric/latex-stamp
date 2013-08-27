#!/usr/bin/env ruby
# encoding: utf-8

require "optparse"
require "yaml"


$options = {}

$options[:group_size] = 12

$options[:groups] = ["A", "B", "C"]

$options[:template] = nil

OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [$options]"

  $options[:paperformat] = "a4paper"
  opts.on("-p", "--paperformat s", "paper format (default: a4paper),","as accepted by koma-script,", "e.g. a4paper, a5paper, letterpaper") do |v|
        $options[:paperformat] = v
  end
  $options[:test] = false
  opts.on("-T", "--[no-]test", "only produce one sheet") do |v|
        $options[:test] = v
  end
  opts.on("--groups g1,g2,g3", Array, "group prefices (at least one,","default: A,B,C)") do |list|
    $options[:groups] = list
  end
  opts.on("-s n", "--size", OptionParser::DecimalInteger, "size of groups (default: 12)") do |i|
    $options[:group_size] = i
  end

  opts.on("-t", "--template t", "set LaTeX template from file") do |t|
    if File.exists?(t) and File.readable?(t)
      $options[:template] = File.read t
    else
      STDERR.puts("Warning: File does not exist «%s»." % [t])
      STDERR.puts("--> using standard template.")
    end
  end

end.parse!

def clean_files(files)
  files.each do |k,v|
    v.reject! do |f|
      fr = ! File.readable?(f)
      STDERR.puts "#{f} not readable; will not be used!" if fr
      fr
    end
  end
end


require "random_memory"
random_numbers = RandomMemory.new(upper_limit: 9999)

require "tex_tag"

all_file = "ALL.yaml"
if FileTest.readable? all_file
  to_process = YAML.load_file all_file
else
  to_process = {}
end

clean_files(to_process)


stamp = TeXTag.new(paperformat: $options[:paperformat],
                   template: $options[:template])
$stamping = {
  :cover => stamp.method(:cover_file),
  :sheet => stamp.method(:tag_file)
}

$to_process_group = Hash.new{ |h,k| h[k] = Hash.new }
$options[:groups].each do |group|
  group_file = "#{group.to_s}.yaml"
  if FileTest.readable? group_file
    $to_process_group[group] = YAML.load_file group_file
  end
  $stamping.each_key do |part|
    $to_process_group[group][part.to_s] ||= []
    $to_process_group[group][part.to_s] += to_process[part.to_s] || []
    STDERR.puts "»#{part}« file list empty for group #{group}. Don't be surprised that there will be no output." if $to_process_group[group][part.to_s].empty?
  end
  clean_files($to_process_group[group])
end

def personalize (number, group)
  # BUG: Don't load yaml *here*!
  $to_process_group[group].each do |part, files|
    files.each do |f|
      STDERR.puts "--> Processing «#{f}» #{group}, \# #{number}"
      $stamping[part.to_sym].call(f, number)
    end
  end
end



i = 0  # counter for number of sheets

$options[:groups].each do |g|
  unless $options[:test]
    to_generate = (i .. (i + $options[:group_size] -1))
  else
    to_generate = [1]
  end
  to_generate.each do |n|
    personalize("%<g>s-%04<nr>d" % {nr:random_numbers.get_number, g:g}, g)
  end
  i += $options[:group_size]
end
