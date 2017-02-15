require "dotenv"
require "lib/appsignal_markdown"

Dotenv.load

DOCS_ROOT   = File.expand_path(File.dirname(__FILE__))
GITHUB_ROOT = "https://github.com/appsignal/appsignal-docs/tree/master"

GRAPHQL_OBJECTS = data.graphql.data['__schema']['types']
  .select  { |t| t['kind'] == 'OBJECT'}
  .reject  { |t| t['name'] == 'Query' || t['name'].start_with?('__') }
  .sort_by { |t| t['name'] }

GRAPHQL_INTERFACES = data.graphql.data['__schema']['types']
  .select  { |t| t['kind'] == 'INTERFACE' }
  .reject  { |t| t['name'].start_with?('__') }
  .sort_by { |t| t['name'] }

GRAPHQL_SCALARS = data.graphql.data['__schema']['types']
  .select  { |t| t['kind'] == 'SCALAR' }
  .reject  { |t| t['name'].start_with?('__') }
  .sort_by { |t| t['name'] }

GRAPHQL_ENUMS = data.graphql.data['__schema']['types']
  .select  { |t| t['kind'] == 'ENUM' }
  .reject  { |t| t['name'].start_with?('__') }
  .sort_by { |t| t['name'] }

GRAPHQL_UNIONS = data.graphql.data['__schema']['types']
  .select  { |t| t['kind'] == 'UNION' }
  .reject  { |t| t['name'].start_with?('__') }
  .sort_by { |t| t['name'] }

Time.zone = "Amsterdam"

set :layout, :article
set :markdown_engine, :redcarpet
set :markdown, AppsignalMarkdown::OPTIONS.merge(renderer: AppsignalMarkdown)
set :haml, :attr_wrapper => %(")
set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

activate :syntax, :line_numbers => true

GRAPHQL_OBJECTS.each do |obj|
  proxy "/graphql/objects/#{obj['name'].underscore}.html", "/graphql/object.html", :locals => { :obj => obj }, :ignore => true
end

GRAPHQL_INTERFACES.each do |obj|
  proxy "/graphql/interfaces/#{obj['name'].underscore}.html", "/graphql/interface.html", :locals => { :obj => obj }, :ignore => true
end

GRAPHQL_SCALARS.each do |obj|
  proxy "/graphql/scalars/#{obj['name'].underscore}.html", "/graphql/scalar.html", :locals => { :obj => obj }, :ignore => true
end

GRAPHQL_ENUMS.each do |obj|
  proxy "/graphql/enums/#{obj['name'].underscore}.html", "/graphql/enum.html", :locals => { :obj => obj }, :ignore => true
end

GRAPHQL_UNIONS.each do |obj|
  proxy "/graphql/unions/#{obj['name'].underscore}.html", "/graphql/union.html", :locals => { :obj => obj }, :ignore => true
end


helpers do
  def link_with_active(name, path)
    link_to(
      name,
      path,
      :class => ('active' if path == "/#{current_path}")
    )
  end

  def edit_link
    page_path = current_page.source_file
    link_to('Create a pull request', page_path.gsub(DOCS_ROOT, GITHUB_ROOT))
  end

  def graphql_query
    data.graphql.data['__schema']['types'].find { |t| t['name'] == 'Query'}
  end

  def graphql_objects;    GRAPHQL_OBJECTS;    end
  def graphql_interfaces; GRAPHQL_INTERFACES; end
  def graphql_scalars;    GRAPHQL_SCALARS;    end
  def graphql_enums;      GRAPHQL_ENUMS;      end
  def graphql_unions;     GRAPHQL_UNIONS;     end
end

configure :build do
  activate :gzip
  activate :minify_css
  activate :cache_buster
end

activate :s3_sync do |s3|
  s3.aws_access_key_id     = ENV['AWS_DOCS_ID']
  s3.aws_secret_access_key = ENV['AWS_DOCS_KEY']
  s3.bucket                = ENV['AWS_DOCS_BUCKET']
  s3.region                = 'eu-west-1'
  s3.prefer_gzip           = true
end

activate :cloudfront do |cf|
  cf.access_key_id     = ENV['AWS_DOCS_ID']
  cf.secret_access_key = ENV['AWS_DOCS_KEY']
  cf.distribution_id   = ENV['AWS_DOCS_CF']
end
