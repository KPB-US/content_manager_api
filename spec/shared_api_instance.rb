# shares instance of content manager
# https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-context
RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "shared api instance", shared_context: :metadata do
  # content_manager
  let(:cm) do
    api_uri = 'http://admwebdoc1.borough.kenai.ak.us/CMServiceAPI'
    api_user = 'svc_cmgr_workgroup'
    api_password = ENV['CM_API_PASSWORD']
    api_domain = 'KPB'
    Manager.new(api_uri: api_uri, user: api_user, password: api_password, domain: api_domain)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "shared api instance", include_shared: true
end
