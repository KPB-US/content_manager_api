RSpec.describe Record do
  include_context 'shared api instance'

  it 'can list' do
    records = cm.record.list
    first_result = records.first

    expect(records.count).to eq(250) # current pageSize (arbitrary)
    expect(first_result['TrimType']).to eq('Record')
    expect(first_result).to include('Uri' => a_kind_of(Integer))
  end

  it 'can find by uri' do
    looking_for = '4404'
    records = cm.record.find looking_for
    first_result = records.first

    expect(first_result['Uri']).to eq(looking_for.to_i)
  end

  it 'can find by name' do
    looking_for = 'B10215'
    records = cm.record.find looking_for
    first_result = records.first

    expect(first_result['RecordLatestVersion']['NameString']).to eq(looking_for)
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
      result = cm.record.create(record_type: 'KPB Box', title: 'another test box')
      result['Results'].first
    end

    def create_file(container_uri, classification)
      result = cm.record.create(
        record_type: 'KPB File',
        title: 'another test file',
        container: container_uri,
        classification: classification
      )
      result['Results'].first
    end

    it 'a KPB Box record' do
      box_uri = create_box['Uri']

      expect(box_uri).to a_kind_of(Integer)

      cm.record.delete box_uri
    end

    it 'a KPB File record' do
      box_uri = create_box['Uri']
      file_uri = create_file(box_uri, 'CLK.ELE.33')['Uri']

      expect(file_uri).to a_kind_of(Integer)

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

    it 'a KPB Document record with a file' do
      box_uri = create_box['Uri']
      file_uri = create_file(box_uri, 'CLK.ELE.33')['Uri']
      result = cm.record.create(
        record_type: 'KPB Document', 
        title: 'another test document',
        container: file_uri,
        file_content: 'This is a test file and therefore there is nothing in it.',
        file_name: 'another_test_file.txt'
      )
      first_result = result['Results'].first
      document_uri = first_result['Uri']

      expect(document_uri).to a_kind_of(Integer)

      cm.record.delete document_uri
      cm.record.delete file_uri
      cm.record.delete box_uri
    end

    it 'a KPB Document record without a file' do
      result = cm.record.create(
        record_type: 'KPB Document', 
        title: 'another test document'
      )
      first_result = result['Results'].first
      document_uri = first_result['Uri']

      expect(document_uri).to a_kind_of(Integer)

      cm.record.delete document_uri
    end

    it 'a KPB Document record with fields' do

      result = cm.record.create(
        record_type: 'KPB Document', 
        title: 'another test document',
        fields: { 
          'Subject' => 'This is the subject'
        }
      )
      first_result = result['Results'].first
      document_uri = first_result['Uri']
      fields = first_result['Fields']

      expect(document_uri).to a_kind_of(Integer)
      expect(fields['Subject']).to a_hash_including('Value' => 'This is the subject')

      cm.record.delete document_uri
    end

  end

  it 'can update a document'
end
