class Field < Manager
  FieldStruct = Struct.new(:search_clause_name, :name, :format, :used_by_record_types, :uri)
  
  def list(properties = nil)
    url = @server + '/FieldDefinition'
    get_all_items(url, properties: properties)
  end

  def list_items
    list('properties=Name,SearchClauseName,FieldDefinitionIsUsedByRecordTypes,FieldDefinitionFormat').map do |field|
      FieldStruct.new(
        field['FieldDefinitionSearchClauseName']['Value'],
        field['FieldDefinitionName']['Value'],
        field['FieldDefinitionFormat']['Value'],
        field.fetch('FieldDefinitionIsUsedByRecordTypes', {}).fetch('Value', '').split(',').map(&:strip),
        field['Uri']
      )
    end
  end
end
