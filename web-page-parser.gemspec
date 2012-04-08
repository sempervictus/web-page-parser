Gem::Specification.new do |s|
  s.name    = 'web-page-parser'
  s.version = '0.24'
  s.date    = '2012-03-10'
  s.rubyforge_project = "web-page-parser"
  
  s.summary = "A parser for web pages"
  s.description = "A Ruby library to parse the content out of web pages, such as BBC News pages.  Used by the News Sniffer project. Rewritten for Ruby 1.9+"
  
  s.authors  = ['John Leach', 'RageLtMan']
  s.email    = 'john@johnleach.co.uk', 'rageltman [at] sempervictus]'
  s.homepage = 'https://github.com/sempervictus/web-page-parser'
  
  s.has_rdoc = true

	s.files = Dir.glob("lib/**/*")
	s.test_files = Dir.glob("spec/**/*")

	s.extra_rdoc_files = ["README.rdoc", "LICENSE"]

	s.add_dependency("htmlentities", ">=4.0.0")
end
