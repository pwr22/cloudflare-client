# This file aims to test the failure of an API call

use strict;
use warnings;
use namespace::autoclean;
use Const::Fast;
no indirect 'fatal';

use Test::LWP::UserAgent;
use HTTP::Response;
use JSON::MaybeXS;

use Test::Exception;
use Test::More 'no_plan';

# This is what we will be mocking to return - we set the content later per test
my $mock_http_resp = HTTP::Response->new();

package CloudFlare::Client::Test {
    use Moose;
    use MooseX::StrictConstructor;

    extends 'CloudFlare::Client';

    # Override the real user agent with a mocked one
    sub _build_ua {
        my $mock_ua = Test::LWP::UserAgent->new();

        $mock_ua->map_response( qr{https://api.cloudflare.com/client/v4/},
            $mock_http_resp );

        return $mock_ua;
    }

    __PACKAGE__->meta->make_immutable;
}

# Test upstream failure
my $api = CloudFlare::Client::Test->new( email => 'user', key => 'key' );

const my $ERROR_BODY => q{{
  "result": null,
  "success": false,
  "errors": [{"code":1003,"message":"Invalid or missing zone id."}],
  "messages": []
}};
const my $ERROR_SECTION_REGEX =>    # key order isn't guaranteed
qr/\Q[{"code":1003,"message":"Invalid or missing zone id."}]\E|\Q[{"message":"Invalid or missing zone id.","code":1003}]\E/;

# set the mock
$mock_http_resp->code(400);
$mock_http_resp->header( 'Content-Type' => 'application/json' );
$mock_http_resp->content($ERROR_BODY);

throws_ok { $api->request( 'get' => 'zones/' ) }
qr/\QHTTP request failed with status 400 Bad Request and API reported error(s) \E$ERROR_SECTION_REGEX/,
  "dies and logs body when it exists when HTTP error detected";
