
require 'juggernaut'
require 'juggernaut_helper'

# do this in your individual site instead...
# ActionView::Helpers::AssetTagHelper::register_javascript_include_default('swfobject')
# ActionView::Helpers::AssetTagHelper::register_javascript_include_default('juggernaut')

ActionView::Base.send(:include, Juggernaut::JuggernautHelper)

ActionController::Base.class_eval do
  include Juggernaut::RenderExtension
end
