package CloudFlare::Client::Exception::Connection;
# ABSTRACT: CloudFlare API Connection Exception

use Modern::Perl '2012';
use autodie      ':all';
no  indirect     'fatal';
use namespace::autoclean;

use Readonly;
use Moose; use MooseX::StrictConstructor;
use Types::Standard 'Str';

# VERSION

extends 'Throwable::Error';

has status => (
    is       => 'ro',
    isa      => Str,
    required => 1);

__PACKAGE__->meta->make_immutable;
1; # End of CloudFlare::Client::Exception::Connection

__END__

=head1 SYNOPSIS

Exception class for failures in the CloudFlare API connection

    use CloudFlare::Client::Exception::Connection;

    CloudFlare::Client::Exception::Connection::->throw(
        message   => 'HTTPS connection failure',
        status    => '404'
    );

    my $e = CloudFlare::Client::Exception::Connection::->new(
        message   => 'HTTPS connection failure',
        status    => '404'
    );
    $e->throw;

=attr message

The error message thrown upstream, readonly.

=attr status

The status code for the connection failure

=method throw

On the class, throw a new exception

    CloudFlare::Client::Exception::Connection::->throw(
        message   => 'HTTPS connection failure',
        status    => '404'
    );
    ...

On an instance, throw that exception

    $e->throw;

=method new

Construct a new exception

    my $e = CloudFlare::Client::Exception::Connection::->throw(
        message   => 'HTTPS connection failure',
        errorcode => '404'
    );

=head1 INHERITANCE

See L<Throwable::Error>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cloudflare-client
at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CloudFlare-Client>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CloudFlare::Client::Exception::Upstream

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
