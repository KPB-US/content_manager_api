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
  # cm.create_kpb_file(title: "2020 ABA", container: 689643, classification: 'CLK.ELE.33')
  # cm.create_kpb_document title: 'Banana Document', container: '689679', file_content: File.open('no_monkeys.txt').read, file_name: 'no_monkeys.txt'
  def create(options)
    payload = build_payload_from(options)
    create_record(payload)
  end

  # cm.update_kpb_document title: 'Banana Document Updated', uri: '744321', file_content: File.open('no_monkeys2.txt').read, file_name: 'no_monkeys2.txt'
  def update(options)
    payload = build_payload_from(options.merge(record_new_type: 'Version'))
    create_record(payload)
  end

  def delete(uri)
    payload = {
      DeleteRecordDeleteContents: true
    }
    delete_record uri, payload
  end

  private

  def build_payload_from(options)
    payload = {}
    payload['RecordTitle'] = options[:title] if options.has_key?(:title)
    payload['RecordRecordType'] = options[:record_type] if options.has_key?(:record_type)
    payload['RecordContainer'] =  options[:container].to_s if options.has_key?(:container)
    payload['RecordClassification'] = options[:classification] if options.has_key?(:classification)
    payload['Files'] = [ options[:file_content], { filename: options[:file_name] } ] if options.has_key?(:file_content) && options.has_key?(:file_name)
    payload['Fields'] = formatted_fields(options[:fields]) if options.has_key?(:fields)
    payload['RecordNewType'] = options[:record_new_type] if options.has_key?(:record_new_type)  # 'Version' for updates
    payload['Uri'] = options[:uri].to_s if options.has_key?(:uri)

    payload
  end

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

  def formatted_fields(fields)
    formatted = {}
    fields.each do |key, value|
      formatted[key] = { 'Value' => value }
    end

    formatted
  end
end
