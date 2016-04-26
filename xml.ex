defmodule Moon.Xml do
  alias Moon.Repo
  require Record

  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")

  def create_xml(models) do
    do_create_xml(models)
    |> :xmerl.export_simple(:xmerl_xml, [])
  end

  def do_create_xml([head | tail]) do
    for model <- [head | tail] do
      xml_struct = load_xml_structure(Map.fetch!(model, :__struct__))
      create_xml_element(model, xml_struct)
    end
  end

  def do_create_xml(model) do
    do_create_xml([model])
  end

  # <?xml version="1.0"?>
  # <element att="attribute">
  #   <child />
  # </element>
  defp create_xml_element(model, %{name: name, attributes: attributes, content: [head | tail]}) do
    attribute_list = fetch_attributes(model, attributes)
    child_list = fetch_child_elements(model, [head | tail])
    xmlElement(name: name, attributes: attribute_list, content: child_list)
  end

  # <?xml version="1.0"?>
  # <element att="attribute">
  #   Value
  # </element>
  defp create_xml_element(model, %{name: name, attributes: attributes, content: :string}) do
    attribute_list = fetch_attributes(model, attributes)
    xmlElement(name: name, attributes: attribute_list, content: [create_text(Map.fetch!(model, :value))])
  end

  # <?xml version="1.0"?>
  # <element att="attribute" />
  defp create_xml_element(model, %{name: name, attributes: attributes, content: :empty}) do
    attribute_list = fetch_attributes(model, attributes)
    xmlElement(name: name, attributes: attribute_list, content: [])
  end

  defp fetch_attributes(model, attributes) do
    for attribute <- attributes do
      create_attribute(attribute, Map.fetch!(model, attribute))
    end
  end

  defp fetch_child_elements(parent, elements) do
    for element <- elements do
      child_elements = Repo.all(Ecto.assoc(parent, element))
      create_xml(child_elements)
    end
    |> join_element_list
  end

  defp join_element_list([head | tail]) do
    head ++ join_element_list(tail)
  end

  defp join_element_list(last) do
    last
  end

  defp create_attribute(name, value) do
    xmlAttribute(name: name, value: value)
  end

  defp create_text(value) do
    xmlText(value: value)
  end

  defp load_xml_structure(document_type) do
    document_type =
      to_string(document_type)
      |> String.split(".")
      |> List.last
      |> String.downcase
      |> String.to_atom
    Application.get_env(:phoenix, document_type)
  end
end
