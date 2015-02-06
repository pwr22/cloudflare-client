
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.13

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/CloudFlare/Client.pm',
    'lib/CloudFlare/Client/Exception/Connection.pm',
    'lib/CloudFlare/Client/Exception/Upstream.pm',
    'lib/CloudFlare/Client/Types.pm',
    't/00-compile.t',
    't/01-Exception-Connection.t',
    't/01-Exception-Upstream.t',
    't/01-Types.t',
    't/01-failure-connecting.t',
    't/01-failure-upstream.t',
    't/01-main.t',
    't/01-success.t',
    't/author-01-upstream-existence.t',
    't/author-critic.t',
    't/author-eol.t',
    't/author-no-tabs.t',
    't/release-cpan-changes.t',
    't/release-dist-manifest.t',
    't/release-distmeta.t',
    't/release-kwalitee.t',
    't/release-meta-json.t',
    't/release-minimum-version.t',
    't/release-mojibake.t',
    't/release-pod-coverage.t',
    't/release-pod-linkcheck.t',
    't/release-pod-syntax.t',
    't/release-portability.t',
    't/release-synopsis.t',
    't/release-test-version.t',
    't/release-unused-vars.t'
);

notabs_ok($_) foreach @files;
done_testing;
