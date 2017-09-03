use strict;
use warnings;
use Const::Fast;
use Try::Tiny;

use Test::More 'no_plan';
use Test::Exception;
use Test::LWP::UserAgent;

use HTTP::Response;
use JSON::MaybeXS;

const my $CNT_DATA => decode_json(<<'END_JSON');
{
  "result": {
    "id":"2d4d028de3015345da9420df5514dad0",
    "type":"A",
    "name":"blog.example.com",
    "content":"2.6.4.5",
    "proxiable":true,
    "proxied":false,
    "ttl":1,
    "priority":0,
    "locked":false,
    "zone_id":"cd7d068de3012345da9420df9514dad0",
    "zone_name":"example.com",
    "modified_on":"2014-05-28T18:46:18.764425Z",
    "created_on":"2014-05-28T18:46:18.764425Z"
  },
  "success": true,
  "errors": [],
  "messages": [],
  "result_info": {
    "page": 1,
    "per_page": 20,
    "count": 1,
    "total_count": 200
  }
}
END_JSON

# Reponse from server
const my $CNT_RSP => HTTP::Response->new(200);
$CNT_RSP->header( 'Content-Type' => 'application/json' );
$CNT_RSP->content( encode_json($CNT_DATA) );

package CloudFlare::Client::Test {
    use Moose;
    use MooseX::StrictConstructor;

    extends 'CloudFlare::Client';

    sub _build_ua {
        my $ua = Test::LWP::UserAgent->new;

        $ua->map_response( qr{https://api.cloudflare.com/client/v4/},
            $CNT_RSP );

        return $ua;
    }

    __PACKAGE__->meta->make_immutable;
}

my $api = CloudFlare::Client::Test->new( email => 'user', key => 'KEY' );

lives_and {
    is_deeply( $api->request( 'GET', 'zones' ), $CNT_DATA );
}
"GET request works";
