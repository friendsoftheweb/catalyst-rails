# Catalyst Rails

## Getting Started

Add `catalyst-rails` to your Gemfile and then run `bundle install`.

Next add the necessary script/link tag(s) to your Rails layout:

```erb
<%= catalyst_stylesheet_link_tag(:application) %>
<%= catalyst_javascript_include_tag(:application) %>
```

## Configuration

No configuration is required to get started with Catalyst, but you can change
the following values using a configuration block:

* `environment`: The environment passed to the `catalyst` command when building assets.
* `assets_base_path`: The path which is used by the view helpers when building `<script>` and `<link>` tags in non-development environments. If you are using a CDN which proxies asset requests through a different URL, you should change this in production.
* `dev_server_host`: The host for the Catalyst development server. This should match the host used when running `catalyst server` for development.
* `dev_server_port`: The port for the Catalyst development server. This should match the port used when running `catalyst server` for development.
* `running_feature_tests`: A proc which should return `true` if any RSpec feature tests are being run. By default it returns true if any specs with the metadata `type: :system` are being run.

An example of customizing `assets_base_path`:

```ruby
Catalyst.configure do |config|
  config.assets_base_path = 'https://assets.example.com'
end
```

## Integrating with RSpec

To have Catalyst build your assets before your system/feature tests are run,
add this to the RSpec configuration block in your `spec/rails_helper.rb`:

```ruby
config.before(:suite) { Catalyst.build! }
```

By default, assets are only recompiled if the `yarn.lock` or any JS/SCSS files
have changed and specs with the type `:system` are being run.

If you are not using RSpec or your feature tests are differentiated in another
way, you should override the `running_feature_tests` proc. For example, if you
use the `:feature` type to denote feature tests, you should add this to your
configuration:

```ruby
Catalyst.configure do |config|
  config.running_feature_tests = -> {
    RSpec.world.all_example_groups.any? do |group|
      group.metadata[:type] == :feature
    end
  }
end
```

## Heroku Deployment

To compile assets during the Heroku deployment process, you can create a rake
task in `lib/tasks/assets.rake` to override the default Rails task:

```ruby
namespace :assets do
  desc 'Compile assets with Catalyst'
  task :precompile => 'catalyst:build'
end
```

If you want to compile assets with Catalyst in addition to running the default
Rails task, you can use this instead:

```ruby
Rake::Task['assets:precompile'].enhance(['catalyst:build'])
```
