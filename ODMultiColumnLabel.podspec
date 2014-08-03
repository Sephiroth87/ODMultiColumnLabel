Pod::Spec.new do |s|
  s.name     = 'ODMultiColumnLabel'
  s.version  = '1.0'
  s.license  = 'MIT'
  s.summary  = "A UILabel replacement that renders text on multiple columns"
  s.homepage = 'https://github.com/Sephiroth87/ODMultiColumnLabel'
  s.author   = { 'Fabio Ritrovato' => 'fabio@orangeinaday.com' }
  s.source   = { :git => 'https://github.com/Sephiroth87/ODMultiColumnLabel.git', :tag => '1.0' }

  s.description = 'ODMultiColumnLabel is a UILabel replacement that renders text on multiple columns,' \
                  'without any major hassle'
  s.platform    = :ios

  s.source_files = 'ODMultiColumnLabel/ODMultiColumnLabel*.{h,m,swift}'
  #s.clean_path   = 'Demo'

  s.requires_arc = true
end
