# @summary Gets our admins onto all our servers
#
# Creates accounts for each admin, gets their ssh keys in place, sets an initial password, gets them into right groups, etc.
# Also disables or removes inactive or separated admins.
#
# Note: password is only set at account creation time; user should change immediately
#
# - Active Admins (enabled, etc):
#   - freiheit, Eric Eisenhart
# - Inactive Admins (disabled or removed):
#   - example
#
# @see https://forge.puppet.com/modules/rnelson0/local_user
#
# @example
#   include profile::adminusers
class profile::adminusers {

  # Current active admin users:
  local_user {
    default:
      state            => 'present',
      shell            => '/bin/bash',
      groups           => ['sudo','dnsadm'],
      password         => '$6$34....', # password hash goes here
      password_max_age => 1000,
      manage_groups    => false, # seems to conflict with itself when multiple users have same groups?
      managehome       => true;
    'freiheit':
      comment             => 'Eric Eisenhart',
      ssh_authorized_keys => [
        'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAizH7HspEuIrjHoV8e1MUzWUsxudR+57qOSrQVO8fvFIRy1bw0w07/A7axpC3F2SXmkGJ0+CNiFhkDVjGNdm4bmrJRDm8x+Y36ZO0Ilt1vRTRTDNsoJRuddEyxaX/2SBRs/Tx2/W29ou1I9g1J7ly0786cJc0QWbyT250hS+ZP1fkuO+MqT/M9KSdzvIFZI+uLtiVx32W80F+ReSHu/zdAsJJ04Wyrc5dNpT4cxAdwHaYpZ4UGIjmoyQ4J63aKEDP56UC38Ya1b+QmVn9zk9hEhm/viB4oRlzzCYcxoIeRkDHJTmnosjGEaVSZNVwqccD9TNlq35fhrbWoJM7gd6AbVJlgNkRm/qt7XKzo8xMyeamyYgxofu3w46yYJsY0KnvXQoJkpEYzsJBf24DVlIAh5MgNQ95B6z1VwAHyJLfXXJQ0n4f6jurkkMFH5A9fOIzVr181W0e5gvgcaglVhM4CU7AvDeDthT8kEaDW1Qmz5jYhzYCkbae5Dt6paWggvkKh38s3/Wq/QoSGkvI8hsFcq4zJOKKCwmsCUOft5yfSqoeudaFkhfjtQq6JSC0kwgq86u8Vpi00x41v5N8ydprAiAEzwvKuAKX6HY/hDFyFXbFEQ4zqZQUzPT56xMDc3CZUAU/nigkq41uPiPRvSSMHHiwy9XZhdRU9l7zQZnZc5U= freiheit@speedy.home.eisenhart.com',
        'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDquXGjSeGHrCakEceLGnNrlfh/bT0uv7NZViikYPhmsFgDzw7k6CZxztHimBDqb0WsJKp6Ixuy4n0ZS0pdmcOhfEaEHwwzoMOl5r9/yhjiov6dFuu8BBIGnbDA9GiIcJxnW3OI6RF9b7nsSdvH97JTyG9A4DEtC6AoRqrf5tcyFOAWbwNpc5Ycde7BwkrzjIpjykJ1AuOVAj5oBKnHZfx0I0aEPXz/07tMc5fvwOz/NelkO6tfgK+y4AkuXMgP1MGMHSuquQ/m3rE1pYSb2uCillXQG1HFbrJsIfy9w6VpTVxanYSblzVLpo7OPuWPFymlZkBL0tcf/fauDNh+n5fVOOqD2XIX0bBwV544LmhTrZWwOPqfx8hF79ueDrhheMJrpxpIFX5PiJIthPYroA8v3V59xQp8B1xlYs8sBW2min2lDzlA7BJSzGI+UnDiNIl5ojXLwBsHqqdc6XX9zKZmPx4y8gr23MH+Co/J/K9T/0fj2b9OAtsc7Nh7aj2bspwqrQvywSmNI0pIGqhGRYHEEL3HX3tuB4j61NGHCaRfyAlai1JJ/xFTjSlpYtcbzOuFKYBZT0CJ2R3jTinj8/w1NYIkw+a8ef4dB2HQyzKY9mSosuMrl1PBTXzFiFryqbxBp9KUVEJscPmQTE5wUnYByghHAaPSGNxLIXVD2JHm3Q== freiheit@gmail.com',
        'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABjQwJOlVQKXyGYgdwaLDS3hmIt+xxvdj/nipdWdSlwy04UHt6PhBcEQO7nOuszYZXQUJqFfN+kebPj8mxBYwafmdSlV54THMLJEbui8+OFvupPSGgFwnoLa7gBphtlp3Lq6QbiXlV8nuEwfEL73VAvrVYvmMspFbKcRu/tlTX+qhRARZc/r1dleMi4wxcEalNLcUXqsHYQFumTSd2PywYCULZZnLFVrHMx6lSgDz0kufTOArE+4DgnHNaGeehvBH3yz7Tm1CC2reqZH9xzxuMsKnTOw78twbF42MGj8he03ZZDcLUbHD1/RsoivQQ8xmAhVaYa+MF4cllyfBi4Q65vFNHgHRYL/JDb9cgKxlPc9KXj9iv05iZoNJK41Ll+VA2qZhaanxjqO++NG5Zowbifw8Csq2wz00uz/B6hSVM2eFYVr7Oec4/sj1b52MkR+f65BAR05Yz/crGW/TnKwX6eC9+Hlo+9KcmNHdSktVmqVcBHvxsp+BGZLUp3v5HqoLAdDxxD+mx858JC9ZJRhE= eisenhae@sonoma.edu',
        'ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFTU4m8z9Ign9TW2PFxqK9hiBIBP5y76NGCeB+SwtGKG80aRnZtnnimmagmJ7jWuHapKtzD3rNP4D+NJ8GeDw/uhgEX0ckYYmMVa8Jf8eHx/IsWrjqMFndgR+UDIssZYBRRXab5yQfOwVeHWt8pn9ax35lXotkyPhEC++xr9EixxI1B0Q== freiheit@monolith.home.eisenhart.com',
      ];
  }

  # Locked users:
  user {
    default:
      password => '!!',
      shell    => '/bin/false';
    ['twr']:
  }

  # Removed users:
  user {
    ['example']:
      ensure => 'absent';
  }
}
