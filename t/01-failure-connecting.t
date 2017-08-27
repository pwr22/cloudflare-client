#!perl -T

# This file aims to test the failure of an API call when a
# connection cannot be made
package CloudFlare::Client::Test;

use strict;
use warnings;
no indirect 'fatal';
use namespace::autoclean;

use Const::Fast;
use Try::Tiny;
use Moose;
use MooseX::StrictConstructor;

use Test::More;
use Test::Exception;
use Test::LWP::UserAgent;

plan tests => 1;

extends 'CloudFlare::Client';

# Override the real user agent with a mocked one
# It will always fail to connect
sub _buildUa { Test::LWP::UserAgent->new }
__PACKAGE__->meta->make_immutable;

# Test upstream failures
# Catch potential failure
const my $API => try {
    CloudFlare::Client::Test->new( user => 'user', apikey => 'KEY' )
}
catch { diag $_ };

# Valid values
const my $ZONE  => 'zone.co.uk';
const my $ITRVL => 20;

throws_ok { $API->action( z => $ZONE, interval => $ITRVL ) }
qr/HTTP request failed with status 404 Not Found/,
  "methods die with a connection error";
