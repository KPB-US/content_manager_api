# ContentManagerApi

A ruby gem for interfacing with Micro Focus Content Manager.
## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'ruby-ntlm', github: 'KPB-US/ruby-ntlm'
gem 'content_manager_api', git: 'git@github.com:KPB-US/content_manager_api'
```

This ruby-ntlm fork has been tweaked to fix a posting bug.  The content_manager_api gem is a private repo.

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install content_manager_api

## Usage

```ruby
  require 'content_manager_api'

  api_uri = 'http://servername/CMServiceAPI'
  api_user = 'username'
  api_password = ENV['CM_API_PASSWORD']
  api_domain = 'domain'
  @manager = Manager.new(api_uri: api_uri, user: api_user, password: api_password, domain: api_domain)    

  result = @manager.record.create(
    record_type: 'Finance Document - Payroll',
    title: 'Timesheet for Johnny Quest',
    file_content: 'contents_of_the_file',
    file_name: 'name_of_the_file.pdf',
    fields: { 
      'EmployeeNo' => '54321',
      'CostCenter' => 'HR',
      'PeriodEnding' => Date.today.iso8601
    }
  )
  first_result = result['Results'].first
  document_uri = first_result['Uri']
  
  puts document_uri

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

**Since this is a private gem, we do not push it to rubygems.**

When running the tests, make sure that you have the `CM_API_PASSWORD` defined in your environment.  If the password is incorrect when the test is run, it may lockout the Windows service account.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/KPB-US/content_manager_api.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
