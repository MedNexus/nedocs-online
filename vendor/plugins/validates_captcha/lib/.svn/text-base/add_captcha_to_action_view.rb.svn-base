require 'action_view'

module AngryMidgetPluginsInc #:nodoc:


	module Helpers #:nodoc:


		# Captcha helper methods. See README for an overview.
		module Captcha


			# Prepares a CAPTCHA challenge to use in a form. This method must
			# be called before using any of the other helper methods,
			# as it returns the object these methods need to work.
			# 
			# Use like this (in your view):
			# 
			# <% c = generate_captcha -%>
			# 
			# It takes the following options:
			# 
			# - :ttl - Time to live. The challenge expires after +ttl+ seconds.
			#   Default is 1200 (20 minutes).
			# - :string - The text to generate in the image. This option probably
			#   has limited use.
			# - :dir - The directory in which to store the generated image.
			# - :filename - The filename to use for the generated image (without the
			#   extension like png or jpg). Default is to generate a random filename.
			# - :filetype - The file extension (and file type) to use for the generated
			#   image. Default is "jpg".
			def prepare_captcha(options = {})
				CaptchaImageChallenge.new(options)
			end


			# Returns an +image+ tag with the image generated in the
			# +challenge+ object.
			# 
			# +options+ takes the following parameters, and the +options+
			# hash is passed on to the +image_tag+ method.
			# 
			# - :fontsize - The font size of the generated text in pt. Default 25.
			# - :padding - The padding put around the text (in px). Should not
			#   be too small if the text is rotated. Default is 20.
			# - :color - Text colour. Default is '#000000' (black).
			# - :background - Background colour. Default is '#ffffff' (white).
			# - :fontweight - Font weight of generated text. Can be "normal"
			#   or "bold". Default is "bold".
			# - :rotate - Whether the text should be rotated or not.
			#   Default is +true+.
			def captcha_image_tag(challenge, options = {})
				challenge.generate(options)
				challenge.write

				image_tag(
					challenge.file_path,
					{
						:size => "#{challenge.image.columns}x#{challenge.image.rows}"
					}.update(options)
				)
			end


			# Creates a hidden input field called <tt>object[captcha_id]</tt>,
			# with +challenge+'s id as value. The +options+ hash is
			# passed on to the +hidden_field+ helper.
			# 
			# This field must be present for the form to validate.
			def captcha_hidden_field(challenge, object, options = {})
				options.merge!({
					:value => challenge.id
				})
				
				hidden_field(object, 'captcha_id', options)
			end


			# Creates a text field for the user to type
			# the solution to the challenge (i.e. the
			# text from the image) into.
			# 
			# The +options+ hash is passed on to the
			# +text_field+ helper.
			# 
			# Must be present for form/model object to validate.
			def captcha_text_field(object, options = {})
				text_field(object, 'captcha_validation', options)
			end


			# Creates a +label+ tag with the +for+ attribute
			# set to +object_captcha_validation+.
			# 
			# The +options+ hash is passed on to the
			# +content_tag+ helper.
			def captcha_label(object, name = 'CAPTCHA validation', options = {})
				options = {
					:for => "#{object}_captcha_validation"
				}.update(options)
				
				content_tag('label', name, options)
			end


			def captcha_ttl(c) #:nodoc:
				c.ttl
			end


		end#module Captcha


	end#module Helpers


end#module AngryMidgetPluginsInc


ActionView::Base.class_eval {
	include AngryMidgetPluginsInc::Helpers::Captcha
}
