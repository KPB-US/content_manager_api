RSpec.describe ContentManagerApi do
  include_context 'shared api instance'
  
  it "has a version number" do
    expect(ContentManagerApi::VERSION).not_to be nil
  end

  it "exposes classification" do
    expect(cm.classification).to be_an_instance_of(Classification)
  end

  it "exposes location" do
    expect(cm.location).to be_an_instance_of(Location)
  end

  it "exposes record" do
    expect(cm.record).to be_an_instance_of(Record)
  end
end
