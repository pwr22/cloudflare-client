package CloudFlare::Client::Types;

# ABSTRACT: Types for Cloudflare::Client

use strict;
use warnings;
no indirect 'fatal';
use namespace::autoclean;

use Type::Library -base, -declare => qw( CFCode ErrorCode);

# Theres a bug about using undef as a hashref before this version
use Type::Utils 0.039_12 -all;
use Types::Standard qw( Enum Maybe);
use Readonly;

# VERSION

class_type 'LWP::UserAgent';
declare CFCode,    as Enum  [qw( E_UNAUTH E_INVLDINPUT E_MAXAPI)];
declare ErrorCode, as Maybe [CFCode];

1;    # End of CloudFlare::Client::Types

__END__

=head1 SYNOPSIS

    use CloudFlare::Client::Types 'ErrorCode';

=cut
