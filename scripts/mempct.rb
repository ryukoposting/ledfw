require 'open3'

MAX_RAM = 0x3bc00
MAX_FLASH = 0xc0000

stdout, stderr, status = Open3.capture3('arm-none-eabi-nm -Crtx --size-sort ./.build/debug.elf')

biggest = []
sum = 0
flash_sum = 0
stdout.lines.each do |line|
    size, loc = line.split
    if ['d', 'b', 'v', 'D', 'B', 'V'].include? loc
        if biggest.length < 5
            biggest.push line
        end
        sum += size.to_i 16
    end

    if ['d', 'v', 'w', 't', 'r', 'D', 'V', 'W', 'T', 'R'].include? loc
        flash_sum += size.to_i 16
    end
end

puts biggest
puts "#{sum} bytes of RAM used (max=#{MAX_RAM}) (#{sum * 100 / MAX_RAM}%)"
puts "#{flash_sum} bytes of FLASH used (max=#{MAX_FLASH}) (#{flash_sum * 100 / MAX_FLASH}%)"

# 43356, 157548
