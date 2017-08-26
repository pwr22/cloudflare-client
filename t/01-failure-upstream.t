#!perl -T

# This file aims to test the failure of an API call
package CloudFlare::Client::Test;

use strict;
use warnings;
no indirect 'fatal';
use namespace::autoclean;

use Const::Fast;
use Readonly;
use Try::Tiny;
use Moose;
use MooseX::StrictConstructor;

use Test::More;
use Test::Exception;
use Test::LWP::UserAgent;
use HTTP::Response;
use JSON::MaybeXS;

plan tests => 2;

extends 'CloudFlare::Client';

# This is what we will be mocking to return - we set the content later
const my $HTTP_RESP_MOCK => HTTP::Response->new(200);

# Override the real user agent with a mocked one
# It will always return the error response $HTTP_RESP_MOCK
sub _buildUa {
    Readonly my $ua => Test::LWP::UserAgent::->new;
    $ua->map_response( qr{www.cloudflare.com/api_json.html}, $HTTP_RESP_MOCK );
    return $ua;
}

__PACKAGE__->meta->make_immutable;

# Test upstream failure
Readonly my $API =>
  CloudFlare::Client::Test->new( user => 'user', apikey => 'KEY' );

# Valid values
Readonly my $ZONE     => 'zone.co.uk';
Readonly my $ITRVL    => 20;
Readonly my $ERR_CODE => 'E_UNAUTH';
Readonly my $ERR_MSG => 'something';

const my $RESP_CONTENT => {    # json body
    result   => 'error',
    err_code => $ERR_CODE,
    msg      => 'something',
};
$HTTP_RESP_MOCK->content( encode_json($RESP_CONTENT) );    # set the mock

throws_ok { $API->action( z => $ZONE, interval => $ITRVL ) }
qr/API errored with code $ERR_CODE and message $ERR_MSG/,
  "methods die with an error response including a code";

const my $RESP_WITHOUT_CODE => {                # json body
    result => 'error',
    msg    => 'something',
};
$HTTP_RESP_MOCK->content( encode_json($RESP_WITHOUT_CODE) );    # set the mock

throws_ok { $API->action( z => $ZONE, interval => $ITRVL ) }
qr/API errored with no error code and message $ERR_MSG/,
  "methods die with an error response including a code";
