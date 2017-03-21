require "middleman-s3_sync"
require "middleman-cloudfront"

desc "Build the website from source"
task :build do
  puts "## Building website"
  status = system("bundle exec middleman build --clean")
  puts status ? "OK" : "FAILED"
end

desc "Run the preview server at http://localhost:4567"
task :preview do
  system("bundle exec middleman server")
end

desc "Deploy website via rsync"
task :deploy do
   puts '## Syncing to S3...'
   system "bundle exec middleman s3_sync"
   puts '## Invalidating cloudfront...'
   system "bundle exec middleman invalidate"
   puts '## Deploy complete.'
end

desc "Clean up the deploy"
task :cleanup do
  puts "## Cleaning build"
  status = system("rm -rf build")
  puts status ? "OK" : "FAILED"
end

desc "Get GraphQL schema from app dir"
task :graphql do
  puts "## Fetching GraphQL"
  system("cp ../appsignal-server/vendor/assets/javascripts/relay/data/schema.json ./data/graphql.json")
end

desc "Build and deploy website"
task :build_deploy => [:build, :deploy, :cleanup]

desc "Generate redirect rules for old pages in the AWS S3 bucket."
task :redirects do
  # A maximum of 50 redirects are supported by AWS S3. Be careful what you redirect!
  redirects = [
    ["contributing", "appsignal/contributing.html"],
    ["getting-started/your-user-account.html", "getting-started/user-account.html"],
    ["getting-started/invite-new-members.html", "organization/team/members.html"],
    ["getting-started/manage-owners-teams.html", "organization/team/owners.html"],
    ["getting-started/set-up-a-new-app.html", "getting-started/new-application.html"],
    ["getting-started/manage-app-settings.html", "application/settings.html"],
    ["getting-started/lifecycle.html", "appsignal/request-lifecycle.html"],
    ["getting-started/how-appsignal-operates.html", "appsignal/how-appsignal-operates.html"],
    ["getting-started/custom-metrics.html", "metrics/custom.html"],
    ["getting-started/host-metrics.html", "metrics/host.html"],
    ["getting-started/integrations.html", "application/integrations/index.html"],
    ["getting-started/integrations/pagerduty.html", "application/integrations/pagerduty.html"],
    ["getting-started/integrations/jira.html", "application/integrations/jira.html"],
    ["getting-started/integrations/intercom.html", "application/integrations/intercom.html"],
    ["getting-started/webhooks.html", "application/integrations/webhooks.html"],
    ["billing/declined-charges.html", "organization/billing.html"],
    ["tweaks-in-your-code/filter-parameter-logging.html", "ruby/configuration/parameter-filtering.html"],
    ["tweaks-in-your-code/integration-appsignal.html", "ruby/instrumentation/integrating-appsignal.html"],
    ["tweaks-in-your-code/handle-exceptions.html", "ruby/instrumentation/handle-exceptions.html"],
    ["ruby/instrumentation/handle-exceptions.html", "ruby/instrumentation/exception-handling.html"],
    ["tweaks-in-your-code/integration-gems.html", "ruby/integrations/appsignal-gems.html"],
    ["tweaks-in-your-code/custom-instrumentation.html", "ruby/instrumentation/index.html"],
    ["tweaks-in-your-code/method-instrumentation.html", "ruby/instrumentation/method-instrumentation.html"],
    ["tweaks-in-your-code/link-templates.html", "ruby/instrumentation/link-templates.html"],
    ["getting-started/supported-frameworks.html", "ruby/integrations/index.html"],
    ["gem-settings/configuration.html", "ruby/configuration/index.html"],
    ["ruby/configuration.html", "ruby/configuration/index.html"],
    ["gem-settings/ignore-actions.html", "ruby/configuration/ignore-actions.html"],
    ["tweaks-in-your-code/ignore-instrumentation.html", "ruby/instrumentation/ignore-instrumentation.html"],
    ["tweaks-in-your-code/frontend-error-catching.html", "front-end/error-handling.html"],
    ["tweaks-in-your-code/background-monitoring.html", "ruby/integrations/index.html"],
    ["background-monitoring/sidekiq.html", "ruby/integrations/sidekiq.html"],
    ["background-monitoring/delayed-job.html", "ruby/integrations/delayed-job.html"],
    ["background-monitoring/resque.html", "ruby/integrations/resque.html"],
    ["background-monitoring/rake.html", "ruby/integrations/rake.html"],
    ["background-monitoring/custom.html", "ruby/instrumentation/background-jobs.html"],
    ["security/overview.html", "appsignal/security.html"],
    ["api/overview.html", "api/index.html"],
    ["ruby/instrumentation/link-templates.html", "application/link-templates.html"]
  ]
  rules = ""
  redirects.each do |old, new|
    rules << <<-STRING
      <RoutingRule>
        <Condition><KeyPrefixEquals>#{old}</KeyPrefixEquals></Condition>
        <Redirect>
          <ReplaceKeyPrefixWith>#{new}</ReplaceKeyPrefixWith>
          <HostName>docs.appsignal.com</HostName>
          <HttpRedirectCode>301</HttpRedirectCode>
        </Redirect>
      </RoutingRule>
      STRING
  end

  puts "Copy the following in the AWS S3 bucket's Redirection Rules configuration box:\n\n"
  puts "<RoutingRules>\n#{rules}</RoutingRules>"
end
