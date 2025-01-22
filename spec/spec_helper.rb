# frozen_string_literal: true

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
require 'webmock/rspec'
allowed_sites = [
  'chromedriver.storage.googleapis.com'
]
WebMock.disable_net_connect!(allow_localhost: true, allow: allowed_sites)

FIXTURES_PATH = File.expand_path('fixtures', __dir__)
require 'simplecov'

SimpleCov.start('rails') do
  # Ignore these because simplecov doesn't detect when traject
  # loads and evals them. See https://github.com/traject/traject/blob/6df447621826b92e26a4675a2f7610f8c78056ff/lib/traject/indexer.rb#L193
  add_filter 'lib/traject/'

  # the upstream default is app + lib, but track_files doesn't respect any
  # applied filters. https://github.com/colszowka/simplecov/issues/610
  track_files 'app/**/*.rb'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = 'spec/examples.txt'

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
