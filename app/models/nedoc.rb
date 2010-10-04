class Nedoc < ActiveRecord::Base
  require 'RMagick'
  belongs_to :user

  # validate numeric for all fields
  validates_numericality_of [:number_ed_beds, :number_hospital_beds, :total_patients_ed, :total_respirators, :longest_admit, :total_admits, :last_patient_wait]

  # NEDOC Score Level Attributes
  @@NedocsColors = ['33b14d', 'fbe92d', 'ff8f29', 'eb2731', 'ee1667', 'dc168d' ]
  @@NedocsMessage = ['Not Busy', 'Busy', 'Extremely Busy but Not Overcrowded', 'Overcrowded', 'Severely Over-Crowded', 'Dangerously Overcrowded']
  
  def self.message(i)
    return @@NedocsMessage[i] rescue false
  end

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
        EmailTemplate.find(:all).each do |template|
          users = self.notify_list.find_all {|x| x.email_template_id == template.id }
          addresses = users.collect { |x| x.notify_address }.compact
          Email.deliver_score_update(self, template, addresses) if addresses.size > 0
        end
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
    
    # Make sure we're still on the scale
    self.nedocs_score = 200 if self.nedocs_score > 200
    self.nedocs_score = 0 if self.nedocs_score < 0

    return self.nedocs_score    
  end
  
  def image_file
    File.join(RAILS_ROOT, 'public', 'images', self.nedocs_score.to_s + ".gif")
  end
  
  def score_box_image_file
    mini_box_dir = File.join(RAILS_ROOT, 'public', 'images', 'minibox')
    FileUtils.mkdir_p mini_box_dir unless File.directory? mini_box_dir
    File.join(mini_box_dir, self.nedocs_score.to_s + ".png")
  end
  
  def image
    self.create_image
    return self.image_file
  end
  
  def score_box_image
    self.create_score_box_image
    return self.score_box_image_file
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
      im = Magick::Image::read(File.join(RAILS_ROOT, 'public', 'images', 'NEDOCS_gradient.jpg'))[0]
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
  
  def create_score_box_image
    # if File.exists?(self.score_box_image_file)
    #  return true
    # else
      new_image = Magick::Image.new(150,50) { self.background_color = 'lightgray'}
      gradient = Magick::Image::read(File.join(RAILS_ROOT, 'public', 'images', 'NEDOCS_gradient.jpg'))[0]
      gradient.resize!(0.20)
      gradient.rotate!(90)
      new_image.composite!(gradient, Magick::NorthWestGravity, Magick::OverCompositeOp)
      
      text = Magick::Draw.new
      text.annotate(new_image, 0, 0, 0, 60, "My friend!") {
          self.gravity = Magick::WestGravity
          self.pointsize = 16
          self.stroke = 'transparent'
          self.fill = '#000000'
          self.font_weight = Magick::BoldWeight
          }
          
      new_image.write(self.score_box_image_file)
      return true
    # end
  end
  
  def level
    return ((Float(self.nedocs_score + 19) / 40)).floor
  end

  def color
    return @@NedocsColors[self.level] rescue "FFFFFF"
	end
	
	def message
    return @@NedocsMessage[self.level] rescue "&nbsp;"
  end
  
  def custom_message
    if self.level == 0 then
      return Setting.level_0_instructions
    elsif self.level == 1 then
      return Setting.level_1_instructions
    elsif self.level == 2 then
      return Setting.level_2_instructions
    elsif self.level == 3 then
      return Setting.level_3_instructions
    elsif self.level == 4 then
      return Setting.level_4_instructions
    elsif self.level == 5 then
      return Setting.level_5_instructions
    else
      return ""
    end
  end
  
  def self.graph_recent
    require 'google_chart'
    nedocs = Nedoc.find(:all, :conditions => ["created_at > ?", 6.months.ago], :order => ["created_at ASC"])
    data = nedocs.collect { |x| [x.created_at.to_i-nedocs[0].created_at.to_i ,x.nedocs_score] }
    sc = GoogleChart::ScatterChart.new('400x200',nil)
    sc.data "NEDOCS", data
    sc.show_legend = false
    sc.axis :y, :labels => [0,20,40,60,80,100,120,140,160,180,200] 
    sc.axis :x, :labels => [nedocs[0].created_at.localtime.strftime("%m-%d-%Y"), nedocs.last.created_at.localtime.strftime("%m-%d-%Y")]
    sc.max_value [data[data.size-1][0], 200]
    
    sc.fill(:chart, :solid, {:color => 'ededed'})
    sc.fill(:background, :solid, {:color => 'ededed'})
    return sc.to_url
  end
  
  def self.graph_recent_data
    # pull up the last years worth of data, or the last 500 points
    local_time_zone = Setting.time_zone
    
    Nedoc.find(:all, :conditions => ["created_at > ?", 12.month.ago], :order => ["created_at DESC"], :limit => 500).collect { |x| "[#{TimeZone.new(local_time_zone).utc_to_local(x.created_at).to_i*1000},#{x.nedocs_score}]" }
  end
  
  def self.graph_by_time_of_day
    local_time_zone = Setting.time_zone
    Nedoc.find_by_sql("select *, TIME(created_at) as created_time from nedocs WHERE number_ed_beds < 999 ORDER BY created_time DESC LIMIT 100").collect { |x| "[#{TimeZone.new(local_time_zone).utc_to_local(Time.parse(x.created_time)).to_i*1000},#{x.nedocs_score}]"}
    
  end
  
end
