source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'figaro'


gem 'bootsnap', '>= 1.4.4', require: false
gem 'jsonapi-serializer'
gem 'jsom-pagination'
gem 'jsonapi_errors_handler'
gem "octokit", "~> 4.0"
gem 'image_processing', '~> 1.2'


group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 5.0.0'
  gem 'factory_bot_rails'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
  gem 'rubocop'
  gem 'sorbet'
  gem 'sorbet-runtime'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
