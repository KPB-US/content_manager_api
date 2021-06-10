RSpec.describe Location do
  include_context "shared api instance"

  it "can list" do
    locations = cm.location.list
    first_result = locations.first

    expect(locations.count).to be > 100 # we know we have more than this default page size
    expect(first_result['TrimType']).to eq('Location')
    expect(first_result).to include('Uri' => a_kind_of(Integer))
  end
end
