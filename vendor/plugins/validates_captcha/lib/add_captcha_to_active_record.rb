require 'active_record'

module AngryMidgetPluginsInc #:nodoc:


	module Validations #:nodoc:


		# module Captcha
		module Captcha #:nodoc:


			def self.append_features(base) #:nodoc:
				super
				base.extend(ClassMethods)
			end


			# Class methods to be used in your models.
			module ClassMethods


				# Validates a CAPTCHA challenge.
				# 
				#   class MySuperModel
				#     validates_captcha :message => "Nope, that wasn't it at all."
				#   end
				# 
				# This method adds two accessors to your model, +captcha_id+ and +captcha_validation+, and
				# makes them accessible for mass-assignment. They are virtual, so you don't need them in
				# your database table. You will have to assign them values from your form in your controller, but
				# if you do something like <tt>tyra = MySuperModel.new(params[:my_super_model])</tt> and you use
				# the helpers in Helpers::Captcha, this will happen automatically.
				# 
				# It takes the optional <tt>:on</tt> and <tt>:if</tt> parameters, that work like in Rails'
				# built-in validations.
				# 
				#   class MySuperModel
				#     validates_captcha :on => :create, :if => Proc.new{|r| !r.user }
				#   end
				def validates_captcha(options = {})
					options = {
						:message => 'CAPTCHA validation did not match.'
					}.update(options)

					include AngryMidgetPluginsInc::Validations::Captcha::InstanceMethods

					class_eval {
						attr_accessor :captcha_id, :captcha_validation
						attr_accessible :captcha_id, :captcha_validation if accessible_attributes

						send(validation_method(options[:on] || :save)){|record|
							unless options[:if] && !evaluate_condition(options[:if], record)
								record.send(:validate_captcha, options)
							end
						}
					}
				end


			end#module ClassMethods


			# module InstanceMethods
			module InstanceMethods #:nodoc:


			private

				def validate_captcha(options = {}) #:nodoc:
					captcha = nil
					CaptchaConfig.store.transaction{|s|
						captcha = s[:captchas] && s[:captchas].find{|c| c.id == captcha_id }
					}

					if captcha
						if !captcha.correct?(captcha_validation)
							errors.add('captcha', options[:message])
						elsif Time.now > captcha.created_at+captcha.ttl
							errors.add('captcha', 'CAPTCHA expired.')
						end
					else
						errors.add('captcha', 'CAPTCHA not found.')
					end
				end


			end


		end#module Captcha


	end#module Validations


end#module AngryMidgetPluginsInc


ActiveRecord::Base.class_eval {
	include AngryMidgetPluginsInc::Validations::Captcha
}
