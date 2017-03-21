require "dotenv"
require "lib/appsignal_markdown"
require 'graphql_schema'
require 'json'

Dotenv.load

DOCS_ROOT   = File.expand_path(File.dirname(__FILE__))
GITHUB_ROOT = "https://github.com/appsignal/appsignal-docs/tree/master"

schema = GraphQLSchema.new(data.graphql)

GRAPHQL_OBJECTS = schema.types.select(&:object?).reject(&:builtin?)

GRAPHQL_INTERFACES = schema.types.select(&:interface?)

GRAPHQL_SCALARS = schema.types.select(&:scalar?)

GRAPHQL_ENUMS = schema.types.select(&:enum?)

GRAPHQL_UNIONS = schema.types.select(&:union?)

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
  proxy "/graphql/object/#{obj.name.underscore}.html", "/graphql/object.html", :locals => { :obj => obj }, :ignore => true
end

GRAPHQL_INTERFACES.each do |obj|
  proxy "/graphql/interface/#{obj.name.underscore}.html", "/graphql/interface.html", :locals => { :obj => obj }, :ignore => true
end

GRAPHQL_ENUMS.each do |obj|
  proxy "/graphql/enum/#{obj.name.underscore}.html", "/graphql/enum.html", :locals => { :obj => obj }, :ignore => true
end

GRAPHQL_UNIONS.each do |obj|
  proxy "/graphql/union/#{obj.name.underscore}.html", "/graphql/union.html", :locals => { :obj => obj }, :ignore => true
end


helpers do
  def link_with_active(name, path)
    link_to(
      name,
      path,
      :class => ('active' if path == "/#{current_path}")
    )
  end

  def type_link(type)
    # Objects/Interfaces have dedicated pages
    path = if %w(OBJECT INTERFACE UNION).include?(type.kind)
      "/graphql/#{type.unwrap.kind.downcase}/#{(type.unwrap.name).try(:underscore) }.html"

    # The rest has a single page
    else
      "/graphql/#{type.unwrap.kind.downcase}.html##{(type.unwrap.name).try(:underscore) }"
    end
    link_to type.unwrap.name, path
  end

  def field_link(field)
    type_link(field.type.unwrap)
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
