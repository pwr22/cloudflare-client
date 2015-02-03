package CloudFlare::Client::Exception::Upstream;
# ABSTRACT: Upstream CloudFlare API Exception

use Modern::Perl '2013';
use autodie      ':all';
no  indirect     'fatal';
use namespace::autoclean;

use Readonly;
use Moo; use MooX::StrictConstructor;
use CloudFlare::Client::Types 'ErrorCode';

# VERSION

extends 'Throwable::Error';

has errorCode => (
    is       => 'ro',
    isa      => ErrorCode);

__PACKAGE__->meta->make_immutable;
1; # End of CloudFlare::Client::Exception::Upstream

__END__

=head1 SYNOPSIS

Exception class that propagates errors from the CloudFlare API

    use CloudFlare::Client::Exception::Upstream;

    CloudFlare::Client::Exception::Upstream::->throw(
        message   => 'Bad things occured',
        errorCode => 'E_MAXAPI'
    );

    my $e = CloudFlare::Client::Exception::Upstream::->new(
        message   => 'Bad things happened',
        errorcode => 'E_MAXAPI'
    );
    $e->throw;

=attr message

The error message thrown upstream, readonly.

=attr errorCode

The error code thrown upstream, readonly. Valid values are undef,
E_UNAUTH, E_INVLDINPUT or E_MAXAPI.

=method throw

On the class, throw a new exception

    CloudFlare::Client::Exception::Upstream::->throw(
        message   => 'Bad things occured',
        errorCode => 'E_MAXAPI'
    );
    ...

On an instance, throw that exception

    $e->throw;

=method new

Construct a new exception

    my $e = CloudFlare::Client::Exception::Upstream::->new(
        message   => 'Bad things happened',
        errorcode => 'E_MAXAPI'
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
