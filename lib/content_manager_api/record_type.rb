class RecordType < Manager
  RecordTypeStruct = Struct.new(:name, :uri)
  
  def list(properties = nil)
    url = @server + '/RecordType'
    get_all_items(url, properties: properties)
  end

  def list_items
    list('properties=Name,Uri').map do |field|
      RecordTypeStruct.new(
        field['RecordTypeName']['Value'],
        field['Uri']
      )
    end
  end
end
