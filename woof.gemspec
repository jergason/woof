spec = Gem::Specification.new do |s|
  s.name = 'woof'
  s.version = '0.0.1'
  s.summary = "Woof is a Ruby parser for the ARFF file format used by the WEKA\n machine learning tool among other things. It is\n very rudimentary, and handles only the most basic cases.\n"
  s.email = 'jergason@gmail.com'
  s.files =  ['lib/woof.rb'] + Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.date = File.mtime('README')
  s.author = "Jamison Dance"
  s.description = s.summary
end
