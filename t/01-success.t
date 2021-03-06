#!perl -T

# This file aims to test the correct functioning of all API calls
package CloudFlare::Client::Test;

use strict;
use warnings;
use namespace::autoclean;

use Const::Fast;
use Try::Tiny;
use Moose;
use MooseX::StrictConstructor;

use Test::More;
use Test::Exception;
use Test::LWP::UserAgent;
use HTTP::Response;
use JSON::MaybeXS;

plan tests => 1;

extends 'CloudFlare::Client';

# Build a simple valid response
# Response payload
const my $RSP_PL => { val => 1 };

# Full response
const my $CNT_DATA => { result => 'success', response => $RSP_PL };

# Reponse from server
const my $CNT_RSP => HTTP::Response->new(200);
$CNT_RSP->content( encode_json($CNT_DATA) );

# Override the real user agent with a mocked one
# It will always return the valid response $CNT_RSP
sub _buildUa {
    my $ua = Test::LWP::UserAgent->new;
    $ua->map_response( qr{www.cloudflare.com/api_json.html}, $CNT_RSP );
    return $ua;
}
__PACKAGE__->meta->make_immutable;

# Catch potential failure
const my $API => try {
    CloudFlare::Client::Test->new( user => 'user', apikey => 'KEY' )
}
catch { diag $_ };

# Valid values
const my $ZONE  => 'zone.co.uk';
const my $ITRVL => 20;
lives_and {
    is_deeply $API->action( zone => $ZONE, interval => $ITRVL ), $RSP_PL
}
"action works";
