RSpec.describe Record do
  include_context 'shared api instance'

  it 'can list' do
    records = cm.record.list
    first_result = records.first

    expect(records.count).to eq(250) # current pageSize (arbitrary)
    expect(first_result['TrimType']).to eq('Record')
    expect(first_result['Uri']).to_not be_nil
  end

  it 'can find by uri' do
    records = cm.record.find '4404'
    first_result = records.first

    expect(first_result['Uri']).to eq(4404)
  end

  it 'can find by name' do
    records = cm.record.find 'B10215'
    first_result = records.first

    expect(first_result['RecordLatestVersion']['NameString']).to eq('B10215')
  end

  it 'reports when cannot find a record' do
    expect do 
      cm.record.find '99994404'
    end.to raise_error('Unable to find object 99994404')
  end

  it 'can search by title' do
    records = cm.record.list '(title:frederickson*)'
    first_result = records.first
    record_title = first_result['RecordTitle']['Value']

    expect(record_title).to match(/frederickson/i)
  end

  context 'create' do
    def create_box
      result = cm.record.create_kpb_box(title: 'another test box')
      result['Results'].first
    end

    def create_file(container_uri, classification)
      result = cm.record.create_kpb_file(
        title: 'another test file', 
        container: container_uri, 
        classification: classification
      )
      result['Results'].first
    end

    it 'a KPB Box record' do
      box_uri = create_box['Uri']

      expect(box_uri).to_not be_nil

      cm.record.delete box_uri
    end

    it 'a KPB File record' do
      box_uri = create_box['Uri']
      file_uri = create_file(box_uri, 'CLK.ELE.33')['Uri']

      expect(file_uri).to_not be_nil

      cm.record.delete file_uri
      cm.record.delete box_uri
    end

    it 'reports when classification is unknown' do
      box_uri = create_box['Uri']

      expect do
        create_file(box_uri, 'CLK.ELE.33X')
      end.to raise_error('Error with field named: Classification. Unable to find object CLK.ELE.33X')

      cm.record.delete box_uri
    end

    it 'a KPB Document record' do
      box_uri = create_box['Uri']
      file_uri = create_file(box_uri, 'CLK.ELE.33')['Uri']
      result = cm.record.create_kpb_document(
        title: 'another test document',
        container: file_uri,
        file_content: 'This is a test file and therefore there is nothing in it.',
        file_name: 'another_test_file.txt'
      )
      first_result = result['Results'].first
      document_uri = first_result['Uri']

      expect(document_uri).to_not be_nil

      cm.record.delete document_uri
      cm.record.delete file_uri
      cm.record.delete box_uri
    end
  end

  it 'can update a document'
end
