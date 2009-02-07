class Nedoc < ActiveRecord::Base
  belongs_to :user

  # after_create :calc_score
  # validates_presence_of [:number_ed_beds, :number_hospital_beds, :total_patients_ed, :total_respirators, :longest_admit, :total_admits, :last_patient_wait]
  
  # validate numeric for all fields
  validates_numericality_of [:number_ed_beds, :number_hospital_beds, :total_patients_ed, :total_respirators, :longest_admit, :total_admits, :last_patient_wait]
  
  def self.latest
    Nedoc.find(:first, :order => "created_at DESC")
  end
  
  def calc_score_and_save
    
    # update the score parameter
    calc_score
    
    if self.save
      return self.nedocs_score if self.notify_list(true).size <= 0
      
      # attempt to deliver email scores
      begin
        Email.deliver_score_update(self)
      rescue Exception => e
        logger.debug "Exception: #{e}"
        log_error(e)
      end
      
      return self.nedocs_score    
    else
      return false
    end
    
  end
    
  def calc_score  

    return false unless self.valid?
    
    # Courtesy of: http://hsc.unm.edu/emermed/nedocs_fin.shtml        
    c = Float(self.number_ed_beds)
		d = Float(self.total_patients_ed)
		e = Float(self.total_respirators)
		f = Float(self.longest_admit)
		g = Float(self.number_hospital_beds)
		h = Float(self.total_admits)
		i = Float(self.last_patient_wait)
    
    # do not allow more than 2 respirators
    e = 2 if e > 2
    
    # make sure we don't divide by 0
    c = 1 if c <= 0
    g = 1 if g <= 0
    
    self.nedocs_score = (-20+(d/c)*85.8+ (h/g)*600+e*13.4+f*0.93 +i*5.64).round
    
    if self.nedocs_score > 200 then
      self.nedocs_score = 200
    end
    
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
    users = User.find(:all, :conditions => ["active = 1 and send_notifications = 1 and notify_threshold <= #{self.nedocs_score}"])
    if email_only
      # return only users with a non nil notify_address
      return users.collect { |x| x.notify_address }.compact
    else
      return users
    end
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
  
  def self.graph_recent
    require 'google_chart'
    # sparklines = GoogleChart::LineChart.new('400x200', nil, false)
    nedocs = Nedoc.find(:all, :conditions => "created_at > #{(6.months.ago).to_i}", :order => ["created_at ASC"])
    data = nedocs.collect { |x| [x.created_at.to_i-nedocs[0].created_at.to_i ,x.nedocs_score] }
    sc = GoogleChart::ScatterChart.new('400x200',nil)
    sc.data "NEDOCS", data
    # sc.point_sizes [10,15,30,55]
    
    # sparklines.data "NEDOCS Score", nedocs.collect{ |x| x.nedocs_score }
    sc.show_legend = false
    # range = data[data.size-1][0] - data[0][0]
    
    sc.axis :y, :range => [0, 200] 
    # sc.axis :x, :range => [data[0][0], data[data.size-1][0]]
    sc.max_value [data[data.size-1][0], 200]
    
    # sparklines.axis :x, :range => [0, 21, 1]
    # sc.max_value 200
    sc.fill(:chart, :solid, {:color => 'ededed'})
    sc.fill(:background, :solid, {:color => 'ededed'})
    return sc.to_url
  end

  
  
  
end
