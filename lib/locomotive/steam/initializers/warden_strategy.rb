# require 'warden'

# Warden::Strategies.add(:steam_password) do

#   def valid?
#     params['auth'].present?
#   end

#   def authenticate!
#     puts "[Warden][steam_password] authenticate!"
#     puts params.inspect

#     entry = nil

#     if type = repositories.content_type.by_slug(params['auth_content_type'])
#       id_field = params['auth_id_field'].try(:to_sym) || :email
#       entry = repositories.content_entry.with(type).all(id_field => params['auth_id']).first

#       entry = nil unless entry.password == params['auth_password']
#     end

#     puts "good? #{entry.password == params['auth_password']}"

#     entry.nil? ? fail!("Could not log in") : success!(entry)

#     # puts entry.name.inspect

#     # # TODO
#     # u = User.authenticate(params['username'], params['password'])
#     # u.nil? ? fail!("Could not log in") : success!(u)
#   end

#   def services
#     @services ||= env['steam.services']
#   end

#   def repositories
#     @repositories ||= services.repositories
#   end
# end
