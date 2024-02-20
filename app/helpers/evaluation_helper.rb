module EvaluationHelper
  def multicriteria_input(position, collection, value=nil)
    if collection.nil?
      text_field_tag "evaluation[x#{position + 1}][]", value, class: "form-control", type: :text
    else
      value = collection.index(value) if value

      select_tag "evaluation[x#{position + 1}][]", options_for_select(collection.each_with_index.map { |e, idx| [e, idx] }, value), value: value, class: "form-control"
    end
  end
end
