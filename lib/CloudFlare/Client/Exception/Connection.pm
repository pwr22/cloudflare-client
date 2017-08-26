package CloudFlare::Client::Exception::Connection;
# ABSTRACT: CloudFlare API Connection Exception

use strict; use warnings; no indirect 'fatal'; use namespace::autoclean;

use Readonly;
use Moose; use MooseX::StrictConstructor;
use Types::Standard 'Str';

# VERSION

extends 'Throwable::Error';

has status => (
    is       => 'ro',
    isa      => Str,
    required => 1,);

__PACKAGE__->meta->make_immutable;
1; # End of CloudFlare::Client::Exception::Connection

__END__

=head1 SYNOPSIS

    use CloudFlare::Client::Exception::Connection;

    CloudFlare::Client::Exception::Connection::->throw(
        message   => 'HTTPS connection failure',
        status    => '404',
    );

    my $e = CloudFlare::Client::Exception::Connection::->new(
        message   => 'HTTPS connection failure',
        status    => '404',
    );
    $e->throw;

=attr message

The error message thrown upstream, readonly

=attr status

The status code for the connection failure, readonly

=method throw

On the class, throw a new exception

    CloudFlare::Client::Exception::Connection::->throw(
        message   => 'HTTPS connection failure',
        status    => '404',
    );
    ...

On an instance, throw that exception

    $e->throw;

=method new

Construct a new exception

    my $e = CloudFlare::Client::Exception::Connection::->throw(
        message   => 'HTTPS connection failure',
        errorcode => '404',
    );

=cut
