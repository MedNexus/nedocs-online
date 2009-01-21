class Nedoc < ActiveRecord::Base
  belongs_to :user

  # after_create :calc_score
  validates_presence_of [:number_ed_beds, :number_hospital_beds, :total_patients_ed, :total_respirators, :longest_admit, :total_admits, :last_patient_wait]
  # validate numeric for all fields
  
  def self.latest
    Nedoc.find(:first, :order => "created_at DESC")
  end
  
  def calc_score
    if self.total_respirators > 2 then
      self.total_respirators = 2
    end
    
    self.nedocs_score = -20+(self.total_patients_ed/self.number_ed_beds)*85.8+(self.total_admits/self.number_hospital_beds)*600+self.total_respirators*13.4+self.longest_admit*0.93+self.last_patient_wait*5.64
    if self.nedocs_score > 200 then
      self.nedocs_score = 200
    end
    self.user_id = ENV['RAILS_USER_ID']
    self.save
    return self.nedocs_score    
  end
  
  def image_file
    File.join(SITE_ROOT, 'public', 'images', self.nedocs_score.to_s + ".png")
  end
  
  def image
    self.create_image
    return self.image_file
  end
  
  def notify_list(email_only=false)
    users = User.find(:all, :conditions => ["active = 1 and notify = 1 and notify_threshold <= #{self.nedocs_score}"])
  end
  
  def create_image
    if File.exists?(self.image_file)
      return true
    else
      im = Magick::Image::read(File.join(SITE_ROOT, 'public', 'images', 'NEDOCS_gradient.jpg'))[0]
      new_image = Magick::Image.new(im.columns+20,im.rows) { self.background_color = 'transparent' }
      new_image.composite!(im,Magick::WestGravity, Magick::OverCompositeOp)
      gc = Magick::Draw.new
      gc.stroke('black')
      gc.stroke_width('5')
      gc.line(0,200-self.nedocs_score,im.columns+20,200-self.nedocs_score)
      gc.draw(new_image)
      new_image.write(self.image_file)
      return true
    end
  end

  def color
		if self.nedocs_score <= 20
			return "33b14d"
		end

		if self.nedocs_score > 20 and self.nedocs_score <= 60
			return "fbe92d"
		end

		if self.nedocs_score > 60 and self.nedocs_score <= 100
			return "ff8f29"
		end

		if self.nedocs_score > 100 and self.nedocs_score <= 140
			return "eb2731"
		end

		if self.nedocs_score > 140 and self.nedocs_score <= 180
			return "ee1667"
		end

		if self.nedocs_score > 180
			return "dc168d"
		end
	end
	
	def message
  	if self.nedocs_score <= 20
  		return "Not Busy"
  	end
	
  	if self.nedocs_score > 20 and self.nedocs_score <=60
  		return "Busy"
  	end
	
  	if self.nedocs_score > 60 and self.nedocs_score <= 100
  		return "Extremely Busy but Not Overcrowded"
  	end
	
  	if self.nedocs_score > 100 and self.nedocs_score <= 140
  		return "Overcrowded"
  	end
	
  	if self.nedocs_score > 140 and self.nedocs_score <= 180
  		return "Severely Over-Crowded"
  	end		
	
  	if self.nedocs_score > 180
  		return "Dangerously Overcrowded"
  	end
  end
  
  
  
end
