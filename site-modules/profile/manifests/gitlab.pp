# profile::gitlab installs gitlab and a gitlab runner
# For configuration options, see:
# - https://forge.puppet.com/puppet/gitlab
# - https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template
# - https://docs.gitlab.com/omnibus/settings/configuration.html
class profile::gitlab {
  class { 'gitlab':
    external_url                 => 'https://gitlab',
    nginx                        => {
      redirect_http_to_https => true,
    },
    gitlab_rails                 => {
      lfs_enabled => true,
    },
    manage_upstream_edition      => 'ee',
    # Set CI/CD workers lower to save memory
    puma => {
      worker_processes => 2,
    },
    # Lower postgresql memory usage
    postgresql                   => {
      shared_buffers => '256MB',
    },
    # lower sidekiq background job processor from 25 to 2 to save memory
    sidekiq                      => {
      concurrency => 2,
    },
    # Disable internal monitoring system to save memory
    prometheus_monitoring_enable => false,
  }

  package { ['docker.io','docker-doc','docker-registry']:
    ensure => installed;
  }
  -> service { 'docker':
    ensure => running,
    enable => true;
  }
  -> class { 'gitlab_ci_runner':
    concurrent => 2,
    runners => {
      'hlp_runner' => {
        'url'                => 'https://gitlab',
        'registration-token' => '???',
        'docker'             => {
          'image' => 'debian:stable',
        },
      },
    },
  }
}
