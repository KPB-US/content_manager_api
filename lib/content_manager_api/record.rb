class Record < Manager
  def find(uri)
    url = @server + "/Record/#{uri}?propertySets=All"
    results = get_response(url)
    results['Results']
  end

  def list(q = nil, all: false)
    url = @server + '/Record'
    get_all_items(url, q: q, all: all)
  end

  # z = cm.create_kpb_box(title: "my.kpb.us DIVISION A box")
  # z['Results'].first['Uri']
  def create_kpb_box(title:)
    payload = { 
      RecordTitle: title,
      RecordRecordType: 3
    }
    create_record(payload)
  end

  # cm.create_kpb_file(title: "2020 ABA", container: 689643, classification: 'CLK.ELE.33')
  def create_kpb_file(title:, container:, classification:)
    payload = { 
      RecordTitle: title,
      RecordRecordType: 1,
      RecordContainer: container,
      RecordClassification: classification
    }
    create_record(payload)
  end

  # cm.create_kpb_document title: 'Banana Document', container: '689679', file_content: File.open('no_monkeys.txt').read, file_name: 'no_monkeys.txt'
  def create_kpb_document(title:, container:, file_content:, file_name:)
    payload = {
      RecordTitle: title,
      RecordRecordType: 'KPB Document',
      RecordContainer: container.to_s,
      "Files" => [ file_content, { filename: file_name } ]
    }
    create_record(payload)
  end

  # cm.update_kpb_document title: 'Banana Document Updated', uri: '744321', file_content: File.open('no_monkeys2.txt').read, file_name: 'no_monkeys2.txt'
  def update_kpb_document(title:, uri:, file_content:, file_name:)
    payload = {
      RecordNewType: 'Version',
      RecordTitle: title,
      Uri: uri.to_s,
      "Files" => [ file_content, { filename: file_name } ]
    }
    create_record(payload)
  end

  def delete(uri)
    payload = {
      DeleteRecordDeleteContents: true
    }
    delete_record uri, payload
  end

  private

  # returns:
  # {
  #   "Results"=>[
  #     {
  #       "RecordRecordType"=>{
  #         "RecordTypeName"=>{
  #           "Value"=>"KPB Box"
  #         }, 
  #         "TrimType"=>"RecordType",
  #         "Uri"=>3,
  #         "Icon"=>{
  #           "IsFileTypeIcon"=>false, 
  #           "IsInternalIcon"=>true, 
  #           "IsValid"=>true, 
  #           "FileType"=>"", 
  #           "Id"=>"DkBlueBox"
  #         }
  #       }, 
  #       "RecordTitle"=>{
  #         "Value"=>"bubba"
  #       }, 
  #       "TrimType"=>"Record", 
  #       "Uri"=>689845
  #     }
  #   ], 
  #   "PropertiesAndFields"=>{}, 
  #   "TotalResults"=>1, 
  #   "MinimumCount"=>0, 
  #   "Count"=>0, 
  #   "HasMoreItems"=>false, 
  #   "TrimType"=>"Record", 
  #   "ResponseStatus"=>{}
  # }
  def create_record(payload)
    url = @server + "/Record"
    response = post_request(url, payload)

    message = response.fetch('ResponseStatus', {}).fetch('Message', '')
    if message && message != ''
      raise message
    end

    response
  end

  def delete_record(uri, payload)
    url = @server + "/Record/#{uri}/Delete"
    post_request(url, payload)
  end
end
