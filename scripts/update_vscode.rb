require 'json'

json = JSON.load File.read(".vscode/c_cpp_properties.json")

mode = ARGV[0]

case mode
when 'i'
    json['configurations'].each do |config|
        case config['name']
        when 'Firmware (Debug)'
            config['includePath'] = ARGV[1..].map { |i| "${workspaceFolder}/#{i}" }
        end
    end
when 'd'
    json['configurations'].each do |config|
        case config['name']
        when 'Firmware (Debug)'
            config['defines'] = ARGV[1..].filter { |flag| flag.start_with? "-D" }.map { |flag| flag[2..] }
            config['defines'].push "VSCODE"
        end
    end
end


File.open(".vscode/c_cpp_properties.json", "w").write JSON.pretty_generate json
