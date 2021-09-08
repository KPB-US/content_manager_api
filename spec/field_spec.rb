RSpec.describe Field do
  include_context "shared api instance"

  it "can list" do
    fields = cm.field.list
    first_result = fields.first

    expect(fields.count).to be > 1
    expect(first_result['TrimType']).to eq('FieldDefinition')
    expect(first_result).to include('Uri' => a_kind_of(Integer))
  end

  it "can list items" do
    fields = cm.field.list_items
    first_result = fields.first

    expect(fields.count).to be > 1
    expect(first_result).to respond_to(:search_clause_name)
  end
end
