module TeacherNotesHelper
  def domain_select(note)
    collection_select :teacher_note, :domain_ids,
      Domain.find(:all),
      :id, 
      :name,
      {},
      :multiple => true,
      :name => 'teacher_note[domain_ids][]' 
  end

  def grade_spans
    GradeSpanExpectation.grade_spans
  end
  
  def domains
    Domain.find(:all)
  end
    
end
