# Aims to test basic usage of CloudFlare::Client

use strict;
use warnings;
use Const::Fast;
no indirect 'fatal';

use Test::More 'no_plan';
use Test::Moose;
use Test::Exception;

use CloudFlare::Client;

const my $EMAIL => 'blah';
const my $KEY   => 'blah';

# Moose tests
const my $CLASS => 'CloudFlare::Client';
meta_ok($CLASS);

for my $attr (qw/ email key _ua /) {
    has_attribute_ok( $CLASS, $attr );
}

lives_and { meta_ok( $CLASS->new( email => $EMAIL, key => $KEY ) ) }
"Instance has meta";

lives_and { new_ok( $CLASS, [ email => $EMAIL, key => $KEY ] ) }
"construction with valid credentials works";

if ( $Moose::VERSION >= 2.1101 ) {    # new mooses throw classes
    const my $MISS_ARG_E => 'Moose::Exception::AttributeIsRequired';

    throws_ok { $CLASS->new( key => $KEY ) } $MISS_ARG_E,
      "construction with missing email attribute throws exception";

    throws_ok { $CLASS->new( email => $EMAIL ) } $MISS_ARG_E,
      "construction with missing key attribute throws exception";

    throws_ok { $CLASS->new( email => $EMAIL, key => $KEY, extra => 'arg' ) }
    'Moose::Exception::Legacy',
      "construction with extra attribute throws exception";
}
else {    # Old Mooses throw strings
    throws_ok { $CLASS->new( key => $KEY ) }
    qr/^Attribute \(_user\) is required/,
      'Construction with missing email attr dies';

    throws_ok { $CLASS->new( email => $EMAIL ) }
    qr/^Attribute \(_key\) is required/,
      'Construction with missing key attr dies';

    throws_ok { $CLASS->new( email => $EMAIL, key => $KEY, extra => 'arg' ) }
    qr/^Found unknown attribute\(s\)/,
      'construction with extra attr throws exception';
}
