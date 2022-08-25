require 'yaml'
require 'stringio'

yaml = YAML.load File.read(ARGV[0])
out = StringIO.new

STDERR.puts "Loading build configuration..."

components = yaml['components']
out.puts "COMPONENTS:=\\"
out.puts components.flatten.map { |component| "#{component}\\" }
out.puts ""

cc = yaml['build']['c']['compiler']
cxx = yaml['build']['cpp']['compiler']
asmc = yaml['build']['asm']['compiler']
out.puts "CC:=#{cc}"
out.puts "CXX:=#{cxx}"
out.puts "ASMC:=#{asmc}"

cflags = yaml['build']['c']['flags'].flatten.map { |flag| "-#{flag}\\" }
cdefines = yaml['build']['c']['defines'].flatten.map { |d| "-D#{d}\\" }
out.puts "CFLAGS:=\\"
out.puts cflags
out.puts cdefines
out.puts ""

cxxflags = yaml['build']['cpp']['flags'].flatten.map { |flag| "-#{flag}\\" }
cxxdefines = yaml['build']['cpp']['defines'].flatten.map { |d| "-D#{d}\\" }
out.puts "CXXFLAGS:=\\"
out.puts cxxflags
out.puts cxxdefines
out.puts ""

asmflags = yaml['build']['asm']['flags'].flatten.map { |flag| "-#{flag}\\" }
asmdefines = yaml['build']['asm']['defines'].flatten.map { |d| "-D#{d}\\" }
out.puts "ASMFLAGS:=\\"
out.puts asmflags
out.puts asmdefines
out.puts ""

yaml['modes'].each do |mode|
    upmode = mode.upcase.gsub(/[ -]+/, '_')

    cflags = yaml['build']['c'].fetch(mode, {}).fetch('flags', []).flatten.map { |flag| "-#{flag}\\" }
    cdefines = yaml['build']['c'].fetch(mode, {}).fetch('defines', []).flatten.map { |d| "-D#{d}\\" }
    out.puts "#{upmode}_CFLAGS:=\\"
    out.puts cflags
    out.puts cdefines
    out.puts ""

    cxxflags = yaml['build']['cpp'].fetch(mode, {}).fetch('flags', []).flatten.map { |flag| "-#{flag}\\" }
    cxxdefines = yaml['build']['cpp'].fetch(mode, {}).fetch('defines', []).flatten.map { |d| "-D#{d}\\" }
    out.puts "#{upmode}_CXXFLAGS:=\\"
    out.puts cxxflags
    out.puts cxxdefines
    out.puts ""

    asmflags = yaml['build']['asm'].fetch(mode, {}).fetch('flags', []).flatten.map { |flag| "-#{flag}\\" }
    asmdefines = yaml['build']['asm'].fetch(mode, {}).fetch('defines', []).flatten.map { |d| "-D#{d}\\" }
    out.puts "#{upmode}_ASMFLAGS:=\\"
    out.puts asmflags
    out.puts asmdefines
    out.puts ""
end

ld = yaml['linker']['ld']
out.puts "LD:=#{ld}"

ldflags = yaml['linker']['flags'].flatten.map { |flag| "-#{flag}\\" }
out.puts "LDFLAGS:=\\"
out.puts ldflags
out.puts ""

ldscript = yaml['linker']['script']
out.puts "LDSCRIPT:=#{ldscript}"

yaml['modes'].each do |mode|
    upmode = mode.upcase.gsub(/[ -]+/, '_')

    flags = yaml['linker'].fetch(mode, {}).fetch('flags', []).flatten.map { |flag| "-#{flag}\\" }
    out.puts "#{upmode}_LDFLAGS:=\\"
    out.puts flags
    out.puts ""
end

nrfutil = yaml['linker']['nrfutil']
out.puts "NRFUTIL:=#{nrfutil}"

objcopy = yaml['linker']['objcopy']
out.puts "OBJCOPY:=#{objcopy}"

out.puts "DFU_KEY_FILE:=#{yaml['dfu']['key-file']}"

out.puts "DFU_SD_REQ:=#{yaml['dfu']['sd-req']}"

out.puts "DFU_APP_VERSION:=#{yaml['dfu']['application-version']}"

out.puts "NRFJPROG:=#{yaml['flash'].fetch('nrfjprog', 'nrfjprog')}"

out.puts "SOFTDEVICE_HEX:=#{yaml['flash']['softdevice']}"

out.puts "BOOTLOADER_HEX:=#{yaml['flash']['bootloader']}"

File.open(ARGV[1], 'w').write out.string
