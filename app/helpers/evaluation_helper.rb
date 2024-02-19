module EvaluationHelper
  def multicriteria_input(position, collection)
    if collection.nil?
      text_field_tag "evaluation[x#{position}][]", "", class: "form-control", type: :text
    else
      select_tag "evaluation[x#{position}][]", options_for_select(collection.each_with_index.map { |e, idx| [e, idx] }), class: "form-control"
    end
  end
end
