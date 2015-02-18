Gem::Specification.new do |s|
  s.name                  = 'minigl'
  s.version               = '2.0.0'
  s.date                  = '2014-12-23'
  s.summary               = 'MiniGL'
  s.description           = 'A minimal 2D Game Library built on top of the Gosu gem.'
  s.authors               = ['Victor David Santos']
  s.email                 = 'victordavidsantos@gmail.com'
  s.files                 = Dir['lib/*.rb', 'lib/minigl/*.rb', 'Rakefile', 'LICENSE', 'README.md']
  s.test_files            = Dir['test/*.rb', 'test/data/*/*']
  s.license               = 'MIT'
  s.homepage              = 'https://github.com/victords/minigl'
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency 'gosu', '~> 0.7'
end
