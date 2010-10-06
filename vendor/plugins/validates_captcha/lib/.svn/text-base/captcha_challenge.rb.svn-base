require 'digest/sha1'

module AngryMidgetPluginsInc #:nodoc:


	# CaptchaChallenge
	class CaptchaChallenge

		include CaptchaConfig
		extend CaptchaConfig

		DEFAULT_TTL = 1200#Lifetime in seconds. Default is 20 minutes.

		attr_reader :id, :created_at
		attr_accessor :ttl



		def initialize(options = {}) #:nodoc:
			generate_id

			options = {
				:ttl => config['default_ttl'] || DEFAULT_TTL
			}.update(options)

			self.ttl = options[:ttl]
			@created_at = Time.now

			self.class.prune
		end


		# Implement in subclasses.
		def correct? #:nodoc:
			raise NotImplementedError
		end



	private

		def generate_id #:nodoc:
			self.id = Digest::SHA1.hexdigest(Time.now.to_s+rand.to_s)
		end


		def id=(i) #:nodoc:
			@id = i
		end


		def write_to_store #:nodoc:
			store.transaction{
				store[:captchas] = Array.new unless store.root?(:captchas)
				store[:captchas] << self
			}
		end



	class << self
	
		# Removes old instances from PStore
		def prune
			store.transaction{
				if store.root?(:captchas)
					store[:captchas].each_with_index{|c,i|
						if Time.now > c.created_at+c.ttl
							store[:captchas].delete_at(i)
						end
					}
				end
			}
		end#prune
	end#class << self


	end



	# A CAPTCHA challenge where an image with text is
	# generated. A human can read the text with relative
	# ease, while most robots can not. There are accessibility
	# problems with this challenge, though, as people
	# with reduced or no vision are unlikely to pass the test.
	class CaptchaImageChallenge < CaptchaChallenge
		require 'RMagick'

		WORDS = 'gorilla costume, superman, banana bender, chuck norris, xray vision, ahoy me hearties,
				 chunky bacon, latex, rupert murdoch, clap your hands, year 2000,
				 sugar coated, coca cola, rastafarian, airbus a380'.split(/,\s+/)
		DEFAULT_DIR = 'captcha'#public/images/captcha
		WRITE_DIR = File.join(RAILS_ROOT, 'public', 'images')
		DEFAULT_FILETYPE = 'jpg'

		attr_reader :image
		attr_accessor :string, :dir, :filename, :filetype


		# Creates an image challenge.
		def initialize(options = {})
			super
			
			options = {
				:string => config['words'] ? config['words'][rand(config['words'].size)] : WORDS[rand(WORDS.size)],
				:dir => config['default_dir'] || DEFAULT_DIR,
				:filetype => config['default_filetype'] || DEFAULT_FILETYPE
			}.update(options)

			self.string = options[:string]
			self.dir = options[:dir]
			self.filetype = options[:filetype]
			self.filename = options[:filename] || generate_filename

			write_to_store
		end


		# Generates the image.
		def generate(options = {})
			options = {
				:fontsize => 25,
				:padding => 20,
				:color => '#000',
				:background => '#fff',
				:fontweight => 'bold',
				:rotate => true
			}.update(options)

			options[:fontweight] = case options[:fontweight]
				when 'bold' then 700
				else 400
			end
			
			text = Magick::Draw.new
			text.pointsize = options[:fontsize]
			text.font_weight = options[:fontweight]
			text.fill = options[:color]
			text.gravity = Magick::CenterGravity
			
			#rotate text 5 degrees left or right
			text.rotation = (rand(2)==1 ? 5 : -5) if options[:rotate]
			
			metric = text.get_type_metrics(self.string)

			#add bg
			canvas = Magick::ImageList.new
			canvas << Magick::Image.new(metric.width+options[:padding], metric.height+options[:padding]){
				self.background_color = options[:background]
			}

			#add text
			canvas << Magick::Image.new(metric.width+options[:padding], metric.height+options[:padding]){
				self.background_color = '#000F'
			}.annotate(text, 0, 0, 0, 0, self.string).wave(5, 50)

			canvas << Magick::Image.new(metric.width+options[:padding], metric.height+options[:padding]){
				p = Magick::Pixel.from_color(options[:background])
				p.opacity = Magick::MaxRGB/2
				self.background_color = p
			}.add_noise(Magick::LaplacianNoise)

			self.image = canvas.flatten_images.blur_image(1)
		end


		# Writes image to file. 
		def write(dir = self.dir, filename = self.filename)
			self.image.write(File.join(WRITE_DIR, dir, filename))
		end


		# Determine if the supplied +string+ matches
		# that used when generating the image.
		def correct?(string)
			string.downcase == self.string.downcase
		end


		# The full path to the image file, relative
		# to <tt>public/images</tt>.
		def file_path
			File.join(dir,filename)
		end



	class << self
	
		# Deletes old image files. Also calls CaptchaChallenge.prune
		def prune
			store.transaction{
				if store.root?(:captchas)
					store[:captchas].each_with_index{|c,i|
						if Time.now > c.created_at+c.ttl
							if File.exists?(File.join(WRITE_DIR, c.file_path))
								begin
									File.unlink(File.join(WRITE_DIR, c.file_path))
								rescue Exception
								end
							end
						end
					}
				end
			}
			super
		end#prune
	end#class << self
		


	private

		def generate_filename #:nodoc:
			self.id+'.'+self.filetype
		end


		def image=(i) #:nodoc:
			@image = i
		end


	end


end
