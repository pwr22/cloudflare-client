#!perl -T

# Aims to test basic usage of CloudFlare::Client
use strict;
use warnings;
no indirect 'fatal';
use namespace::autoclean;

use Const::Fast;
use Try::Tiny;

use Test::More;
use Test::Moose;
use Test::Exception;
use CloudFlare::Client;

plan tests     => 9;
const my $USER => 'blah';
const my $KEY  => 'blah';

# Moose tests
const my $CLASS => 'CloudFlare::Client';
meta_ok($CLASS);

for my $attr (qw/ _user _key _ua/) {
    has_attribute_ok( $CLASS, $attr );
}

lives_and { meta_ok( $CLASS->new( user => $USER, apikey => $KEY ) ) }
"Instance has meta";

lives_and { new_ok( $CLASS, [ user => $USER, apikey => $KEY ] ) }
"construction with valid credentials works";

if ( $Moose::VERSION >= 2.1101 ) {    # new mooses throw classes
    const my $MISS_ARG_E => 'Moose::Exception::AttributeIsRequired';

    throws_ok { $CLASS->new( apikey => $KEY ) } $MISS_ARG_E,
      "construction with missing user attribute throws exception";

    throws_ok { $CLASS->new( user => $USER ) } $MISS_ARG_E,
      "construction with missing apikey attribute throws exception";

    throws_ok { $CLASS->new( user => $USER, apikey => $KEY, extra => 'arg' ) }
    'Moose::Exception::Legacy',
      "construction with extra attribute throws exception";
}
else {    # Old Mooses throw strings
    throws_ok { $CLASS->new( apikey => $KEY ) }
    qr/^Attribute \(_user\) is required/,
      'Construction with missing user attr dies';

    throws_ok { $CLASS->new( user => $USER ) }
    qr/^Attribute \(_key\) is required/,
      'Construction with missing apikey attr dies';

    throws_ok { $CLASS->new( user => $USER, apikey => $KEY, extra => 'arg' ) }
    qr/^Found unknown attribute\(s\)/,
      'construction with extra attr throws exception';
}
