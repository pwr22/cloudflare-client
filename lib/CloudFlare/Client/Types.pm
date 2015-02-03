package CloudFlare::Client::Types;
# ABSTRACT: Types for Cloudflare::Client

use Modern::Perl '2013';
use autodie      ':all';
no  indirect     'fatal';
use namespace::autoclean;

use Type::Library -base, -declare => qw( CFCode ErrorCode);
# Theres a bug about using undef as a hashref before this version
use Type::Utils 0.039_12 -all;
use Types::Standard qw( Enum Maybe);
use Readonly;

# VERSION

class_type 'LWP::UserAgent';
declare CFCode, as Enum[qw( E_UNAUTH E_INVLDINPUT E_MAXAPI)];
declare ErrorCode, as Maybe[CFCode];

1; # End of CloudFlare::Client::Types

__END__

=head1 SYNOPSIS

Provides types used in CloudFlare::Client

    use CloudFlare::Client::Types 'ErrorCode';

Peter Roberts, C<< <me+dev at peter-r.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cloudflare-client
at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CloudFlare-Client>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CloudFlare::Client::Types

You can also look for information at:

=for :list
* DDFlare
L<https://bitbucket.org/pwr22/ddflare>
* RT: CPAN's request tracker (report bugs here)
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CloudFlare-Client>
* AnnoCPAN: Annotated CPAN documentation
L<http://annocpan.org/dist/CloudFlare-Client>
* CPAN Ratings
L<http://cpanratings.perl.org/d/CloudFlare-Client>
* Search CPAN
L<http://search.cpan.org/dist/CloudFlare-Client/>

=cut
