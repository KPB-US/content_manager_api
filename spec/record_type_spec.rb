RSpec.describe RecordType do
  include_context "shared api instance"

  it "can list" do
    results = cm.record_type.list
    first_result = results.first

    expect(results.count).to be > 1
    expect(first_result['TrimType']).to eq('RecordType')
    expect(first_result).to include('Uri' => a_kind_of(Integer))
  end

  it "can list items" do
    results = cm.record_type.list_items
    first_result = results.first

    expect(results.count).to be > 1
    expect(first_result).to respond_to(:name)
  end
end
