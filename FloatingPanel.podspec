Pod::Spec.new do |s|
    s.name         = "FloatingPanel"
    s.version      = "0.1.2"
    s.summary      = "FloatingPanel"
    s.homepage     = "https://github.com/Igor-Palaguta/FloatingPanel"
    s.license      = 'MIT'
    s.author       = { "Igor Palaguta" => "igor.palaguta@gmail.com" }

    s.platform     = :ios, '5.0'
    s.requires_arc = true

    s.header_mappings_dir = 'FloatingPanel'

    s.dependency 'KeyboardHandler'

    s.source_files = 'FloatingPanel/**/*.{h,m}'
end
