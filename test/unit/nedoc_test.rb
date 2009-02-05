require File.dirname(__FILE__) + '/../test_helper'

class NedocTest < Test::Unit::TestCase
  fixtures :nedocs

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_calculation_case_1
    n = Nedoc.new
    n.number_ed_beds = 35
		n.total_patients_ed = 35
		n.total_respirators = 1
		n.longest_admit = 21
		n.number_hospital_beds = 350
		n.total_admits = 14
		n.last_patient_wait = 10
    assert_equal(179, n.calc_score)
  end
  
  def test_calculation_case_2
    n = Nedoc.new
    n.number_ed_beds        = 35
		n.total_patients_ed     = 37
		n.total_respirators     = 0
		n.longest_admit         = 17
		n.number_hospital_beds  = 350
		n.total_admits          = 16
		n.last_patient_wait     = 3
    assert_equal(131, n.calc_score)
  end
  
  def test_calculation_case_3
    n = Nedoc.new
    n.number_ed_beds        = 35
		n.total_patients_ed     = 33
		n.total_respirators     = 0
		n.longest_admit         = 20
		n.number_hospital_beds  = 350
		n.total_admits          = 14
		n.last_patient_wait     = 4
    assert_equal(126, n.calc_score)
  end
  
  def test_calculation_case_4
    n = Nedoc.new
    n.number_ed_beds        = 35
		n.total_patients_ed     = 37
		n.total_respirators     = 0
		n.longest_admit         = 17
		n.number_hospital_beds  = 350
		n.total_admits          = 16
		n.last_patient_wait     = 2.75
    assert_equal(129, n.calc_score)
  end
  
  def test_divide_by_zero_ed_beds
    n = Nedoc.new
    n.number_ed_beds        = 0
		n.total_patients_ed     = 33
		n.total_respirators     = 0
		n.longest_admit         = 20
		n.number_hospital_beds  = 350
		n.total_admits          = 14
		n.last_patient_wait     = 4
    assert_equal(n.calc_score, false)
  end
  
  def test_divide_by_zero_hospital_beds
    n = Nedoc.new
    n.number_ed_beds        = 35
		n.total_patients_ed     = 33
		n.total_respirators     = 0
		n.longest_admit         = 20
		n.number_hospital_beds  = 0
		n.total_admits          = 14
		n.last_patient_wait     = 4
    assert_equal(n.calc_score, false)
  end
  
  def test_missing_data
    n = Nedoc.new
    assert !n.calc_score
  end
  
  def test_alpha_data
    n = Nedoc.new
    n.number_ed_beds = "asdf"
    assert !n.calc_score
  end
  
end
