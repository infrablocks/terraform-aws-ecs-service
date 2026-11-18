# frozen_string_literal: true

require 'confidante'
require 'git'
require 'rake_git'
require 'rake_git_crypt'
require 'rake_github'
require 'rake_gpg'
require 'rake_slack'
require 'rake_ssh'
require 'rake_terraform'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'securerandom'
require 'semantic'

require_relative 'lib/paths'
require_relative 'lib/version'

configuration = Confidante.configuration

def repo
  Git.open(Pathname.new('.'))
end

def latest_tag
  repo.tags.map do |tag|
    Semantic::Version.new(tag.name)
  end.max
end

task default: %i[
  test:code:fix
  test:unit
  test:integration
]

RakeTerraform.define_installation_tasks(
  path: File.join(Dir.pwd, 'vendor', 'terraform'),
  version: '1.3.1'
)

RakeGitCrypt.define_standard_tasks(
  namespace: :git_crypt,

  provision_secrets_task_name: :'secrets:provision',
  destroy_secrets_task_name: :'secrets:destroy',

  install_commit_task_name: :'git:commit',
  uninstall_commit_task_name: :'git:commit',

  gpg_user_key_paths: %w[
    config/gpg
    config/secrets/ci/gpg.public
  ]
)

namespace :git do
  RakeGit.define_commit_task(
    argument_names: [:message]
  ) do |t, args|
    t.message = args.message
  end
end

namespace :encryption do
  namespace :directory do
    desc 'Ensure CI secrets directory exists.'
    task :ensure do
      FileUtils.mkdir_p('config/secrets/ci')
    end
  end

  namespace :passphrase do
    desc 'Generate encryption passphrase for CI GPG key'
    task generate: ['directory:ensure'] do
      File.write(
        'config/secrets/ci/encryption.passphrase',
        SecureRandom.base64(36)
      )
    end
  end
end

namespace :keys do
  namespace :cluster do
    RakeSSH.define_key_tasks(
      path: 'config/secrets/keys/cluster',
      comment: 'maintainers@infrablocks.io'
    )
  end

  namespace :secrets do
    namespace :gpg do
      RakeGPG.define_generate_key_task(
        output_directory: 'config/secrets/ci',
        name_prefix: 'gpg',
        owner_name: 'InfraBlocks Maintainers',
        owner_email: 'maintainers@infrablocks.io',
        owner_comment: 'terraform-aws-ecs-service CI Key'
      )
    end

    task generate: ['gpg:generate']
  end
end

namespace :secrets do
  namespace :directory do
    desc 'Ensure secrets directory exists and is set up correctly'
    task :ensure do
      FileUtils.mkdir_p('config/secrets')
      unless File.exist?('config/secrets/.unlocked')
        File.write('config/secrets/.unlocked', 'true')
      end
    end
  end

  desc 'Generate all generatable secrets.'
  task generate: %w[
    directory:ensure
    encryption:passphrase:generate
    keys:cluster:generate
    keys:secrets:generate
  ]

  desc 'Provision all secrets.'
  task provision: [:generate]

  desc 'Delete all secrets.'
  task :destroy do
    rm_rf 'config/secrets'
  end

  desc 'Rotate all secrets.'
  task rotate: [:'git_crypt:reinstall']
end

RakeGithub.define_repository_tasks(
  namespace: :github,
  repository: 'infrablocks/terraform-aws-ecs-service'
) do |t|
  # Operator's ambient auth. Resolve once and fail fast: a missing, empty,
  # unauthenticated, or absent gh yields an empty string, which would
  # otherwise surface later as an opaque Octokit 401. Treat an empty or
  # whitespace-only GITHUB_TOKEN as absent — fall back to gh, not the raise,
  # so an already-authenticated operator is not told to log in.
  github_token = ENV['GITHUB_TOKEN'].to_s.strip
  if github_token.empty?
    github_token = begin
      `gh auth token`
    rescue Errno::ENOENT
      ''
    end.strip
  end
  if github_token.empty?
    raise 'No GitHub token available: set GITHUB_TOKEN or run `gh auth login`'
  end

  t.access_token = github_token

  # Guard against a locked clone: without it, File.read returns git-crypt
  # ciphertext and github:secrets:ensure silently uploads garbage that only
  # surfaces much later as an opaque GPG unlock failure.
  passphrase_path = 'config/secrets/ci/encryption.passphrase'
  unless File.exist?(passphrase_path)
    raise "#{passphrase_path} not found — provisioning needs the " \
          'git-crypted CI passphrase; run from the repo root in an ' \
          'unlocked clone'
  end
  passphrase = File.binread(passphrase_path)
  if passphrase.start_with?("\x00GITCRYPT")
    raise 'encryption.passphrase is git-crypt ciphertext — unlock the ' \
          'clone before provisioning'
  end
  t.secrets = [
    # dependabot: true also writes it to the Dependabot secret store.
    # Dependabot-triggered runs can read only that store, and this family's
    # test job unlocks git-crypt for AWS credentials — without it every
    # dependabot PR fails its tests and auto-merge never fires.
    { name: 'ENCRYPTION_PASSPHRASE',
      value: passphrase.chomp,
      dependabot: true }
  ]
  t.environments = [
    { name: 'release',
      reviewers: [{ team: 'maintainers' }] }
  ]
end

namespace :slack do
  RakeSlack.define_notification_tasks do |t|
    t.bot_token = ENV.fetch('SLACK_BOT_TOKEN', nil)
    t.routing_rules = [
      { when: { type: 'on_hold' },
        channel: 'C038EDCRSQJ', format: :on_hold },  # release
      { when: { actor: 'dependabot[bot]', outcome: 'success' },
        channel: 'C03N711HVDG', format: :success },  # builds-dependabot
      { when: { actor: 'dependabot[bot]' },
        channel: 'C03N711HVDG', format: :failure },  # builds-dependabot
      { when: { outcome: 'success' },
        channel: 'C023XUE76GH', format: :success },  # builds
      # Failures go to builds, not team-dev (org default), to keep noise
      # out of a popular channel while this pipeline beds in.
      { when: {},
        channel: 'C023XUE76GH', format: :failure } # builds
    ]
  end
end

namespace :repository do
  desc 'Set the git author for CI'
  task :set_ci_author do
    sh 'git config --global user.name "InfraBlocks CI"'
    sh 'git config --global user.email "ci@infrablocks.io"'
  end
end

namespace :pipeline do
  desc 'Prepare GitHub Actions pipeline'
  task prepare: %i[
    github:secrets:ensure
    github:environments:ensure
  ]
end

RuboCop::RakeTask.new

namespace :test do
  namespace :code do
    desc 'Run all checks on the test code'
    task check: [:rubocop]

    desc 'Attempt to automatically fix issues with the test code'
    task fix: [:'rubocop:autocorrect_all']
  end

  desc 'Run module unit tests'
  RSpec::Core::RakeTask.new(unit: ['terraform:ensure']) do |t|
    t.pattern = 'spec/unit/**{,/*/**}/*_spec.rb'
    t.rspec_opts = '-I spec/unit'

    ENV['AWS_REGION'] = configuration.region
  end

  desc 'Run module integration tests'
  RSpec::Core::RakeTask.new(integration: ['terraform:ensure']) do |t|
    t.pattern = 'spec/integration/**{,/*/**}/*_spec.rb'
    t.rspec_opts = '-I spec/integration'

    ENV['AWS_REGION'] = configuration.region
  end
end

namespace :deployment do
  namespace :permanent do
    RakeTerraform.define_command_tasks(
      configuration_name: 'permanent'
    ) do |t, args|
      deployment_configuration =
        configuration.for(:permanent, args)

      t.source_directory = deployment_configuration.source_directory
      t.work_directory = deployment_configuration.work_directory

      t.state_file = deployment_configuration.state_file
      t.vars = deployment_configuration.vars
    end
  end

  namespace :prerequisites do
    RakeTerraform.define_command_tasks(
      configuration_name: 'prerequisites',
      argument_names: [:seed]
    ) do |t, args|
      deployment_configuration =
        configuration
        .for_scope(role: :prerequisites)
        .for_overrides(args.to_h)

      t.source_directory = 'spec/unit/infra/prerequisites'
      t.work_directory = 'build/infra'

      t.state_file = deployment_configuration.state_file
      t.vars = deployment_configuration.vars
    end
  end

  namespace :root do
    RakeTerraform.define_command_tasks(
      configuration_name: 'root',
      argument_names: [:seed]
    ) do |t, args|
      deployment_configuration =
        configuration
        .for_scope(role: :root)
        .for_overrides(args.to_h)

      t.source_directory = 'spec/unit/infra/root'
      t.work_directory = 'build/infra'

      t.state_file = deployment_configuration.state_file
      t.vars = deployment_configuration.vars
    end
  end
end

namespace :version do
  desc 'Bump version for specified type (pre, major, minor, patch)'
  task :bump, [:type] do |_, args|
    next_tag = latest_tag.send("#{args.type}!")
    repo.add_tag(next_tag.to_s)
    repo.push('origin', "refs/tags/#{next_tag}")
    puts "Bumped version to #{next_tag}."
  end

  desc 'Release module'
  task :release do
    # Only release the newest candidate, and only from the commit it tags:
    # approving an older run would otherwise give its commit a newer version.
    tagged = repo.object("#{latest_tag}^{commit}").sha
    unless tagged == repo.object('HEAD').sha
      raise "Latest tag #{latest_tag} is not on HEAD: approve the release " \
            'of the run that created it instead'
    end

    next_tag = latest_tag.release!
    repo.add_tag(next_tag.to_s)
    repo.push('origin', "refs/tags/#{next_tag}")
    puts "Released version #{next_tag}."
  end
end
