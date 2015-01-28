# Dir[File.dirname(__FILE__) + '/entities/*.rb'].each { |file| require file }
# Dir[File.dirname(__FILE__) + '/repositories/*.rb'].each { |file| require file }

# collection :sites do
#   entity     Locomotive::Steam::Entities::Site
#   repository Locomotive::Steam::Repositories::SitesRepository

#   attribute :name
#   attribute :locales
#   attribute :subdomain
#   attribute :domains
#   attribute :seo_title,         localized: true
#   attribute :meta_keywords,     localized: true
#   attribute :meta_description,  localized: true
#   attribute :robots_txt
#   attribute :timezone


# end

# collection :pages do
#   entity     Locomotive::Steam::Entities::Page
#   repository Locomotive::Steam::Repositories::PagesRepository

#   attribute :site, association: {type: :belongs_to, key: :site_id, name: :sites}
#   attribute :content_type, association: {type: :belongs_to, key: :content_type_id, name: :content_types}
#   attribute :parent, association: {type: :belongs_to, key: :parent_id, name: :pages}
#   attribute :children, association: {type: :has_many, key: :parent_id, name: :pages}
#   attribute :title,             localized: true
#   attribute :slug,              localized: true
#   attribute :fullpath,          localized: true
#   attribute :redirect_url,      localized: true
#   attribute :redirect_type,     default: 301
#   attribute :template,          localized: true
#   attribute :handle
#   attribute :listed,            default: false
#   attribute :searchable
#   attribute :templatized,       default: false
#   attribute :content_type
#   attribute :published,         default: true
#   attribute :cache_strategy
#   attribute :response_type
#   attribute :position

#   attribute :seo_title,         localized: true
#   attribute :meta_keywords,     localized: true
#   attribute :meta_description,  localized: true

#   attribute :editable_elements, type: :array, class_name: 'Locomotive::Mounter::Models::EditableElement'

# end

# collection :content_types do
#   entity     Locomotive::Steam::Entities::ContentType
#   repository Locomotive::Steam::Repositories::ContentTypesRepository
#   attribute :slug
#   attribute :site, association: {type: :belongs_to, key: :site_id, name: :sites}
# end

# collection :content_entries do

# end

# collection :content_fields do

# end

# collection :content_select_options do

# end

# collection :editable_elements do

# end

# collection :snippets do

# end

# collection :theme_assets do

# end

# collection :translations do

# end
