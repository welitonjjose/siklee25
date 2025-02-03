class File2Input < SimpleForm::Inputs::Base
  def input(wrapper_options = nil)
    base = wrapper_options.dup()
    base[:id] = "file-input"
    # base[:class] = "input"

    input_html_options.delete(:class)

    merged_input_options = merge_wrapper_options(input_html_options, base)

    @builder.file_field(attribute_name, merged_input_options)
  end
end

# https://codepen.io/swetankrathi/pen/mgBKLQ