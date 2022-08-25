require 'yaml'
require 'stringio'

yaml = YAML.load File.read(ARGV[0])
path = ARGV[2]
out = StringIO.new

includes = yaml.fetch('includes', []).flatten.map { |subdir| "#{File.join path, subdir}\\" }
out.puts "INCLUDE_DIRS:=\\"
out.puts includes
out.puts ""

c_sources = yaml.fetch('c', []).flatten.map { |subdir| "#{File.join path, subdir}\\" }
out.puts "C_SOURCES:=\\"
out.puts c_sources
out.puts ""

cxx_sources = yaml.fetch('cpp', []).flatten.map { |subdir| "#{File.join path, subdir}\\" }
out.puts "CXX_SOURCES:=\\"
out.puts cxx_sources
out.puts ""

asm_sources = yaml.fetch('asm', []).flatten.map { |subdir| "#{File.join path, subdir}\\" }
out.puts "ASM_SOURCES:=\\"
out.puts asm_sources
out.puts ""



File.open(ARGV[1], 'w').write out.string
