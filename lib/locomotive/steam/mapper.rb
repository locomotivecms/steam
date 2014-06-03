Dir[File.dirname(__FILE__) + '/entities/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/repositories/*.rb'].each { |file| require file }

collection :sites do
  entity     Locomotive::Steam::Entities::Site
  repository Locomotive::Steam::Repositories::SitesRepository

  attribute :name
  attribute :locales
  attribute :subdomain
  attribute :domains
  attribute :seo_title,         localized: true
  attribute :meta_keywords,     localized: true
  attribute :meta_description,  localized: true
  attribute :robots_txt
  attribute :timezone


end

collection :pages do
  entity     Locomotive::Steam::Entities::Page
  repository Locomotive::Steam::Repositories::PagesRepository
  attribute :fullpath
  attribute :position
  attribute :site, association: :sites
  attribute :content_type, association: :content_types
end

collection :content_types do
  entity     Locomotive::Steam::Entities::ContentType
  repository Locomotive::Steam::Repositories::ContentTypesRepository
  attribute :slug
  attribute :site, association: :sites
end

collection :content_entries do

end

collection :content_fields do

end

collection :content_select_options do

end

collection :editable_elements do

end

collection :snippets do

end

collection :theme_assets do

end

collection :translations do

end
