RSpec.describe Classification do
  include_context "shared api instance"
  
  it "can list" do
    classifications = cm.classification.list
    first_result = classifications.first

    expect(classifications.count).to be > 250 # we know we have more than this default page size
    expect(first_result['TrimType']).to eq('Classification')
    expect(first_result['Uri']).to_not be_nil
  end

  it "can list codes" do
    codes = cm.classification.codes
    first_result = codes.first

    expect(first_result).to match(/[A-Z0-9]+/)
  end
end
