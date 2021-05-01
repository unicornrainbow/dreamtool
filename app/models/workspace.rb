class Workspace
  include Mongoid::Document

  field :color_palatte, type: Hash
  field :pages_panel, type: Hash
  field :properties_panel, type: Hash
  field :toolbox, type: Hash

  embedded_in :user

end
