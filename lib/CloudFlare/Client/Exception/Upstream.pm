package CloudFlare::Client::Exception::Upstream;
# ABSTRACT: Upstream CloudFlare API Exception

use strict; use warnings; no indirect 'FATAL'; use namespace::autoclean;

use Readonly;
use Moose; use MooseX::StrictConstructor;
use CloudFlare::Client::Types 'ErrorCode';

# VERSION

extends 'Throwable::Error';

has errorCode => (
    is       => 'ro',
    isa      => ErrorCode,);

__PACKAGE__->meta->make_immutable;
1; # End of CloudFlare::Client::Exception::Upstream

__END__

=head1 SYNOPSIS

    use CloudFlare::Client::Exception::Upstream;

    CloudFlare::Client::Exception::Upstream::->throw(
        message   => 'Bad things occured',
        errorCode => 'E_MAXAPI',
    );

    my $e = CloudFlare::Client::Exception::Upstream::->new(
        message   => 'Bad things happened',
        errorcode => 'E_MAXAPI',
    );
    $e->throw;

=attr message

The error message thrown upstream, readonly

=attr errorCode

The error code thrown upstream, readonly. Valid values are undef,
E_UNAUTH, E_INVLDINPUT or E_MAXAPI. Readonly

=method throw

On the class, throw a new exception

    CloudFlare::Client::Exception::Upstream::->throw(
        message   => 'Bad things occured',
        errorCode => 'E_MAXAPI',
    );
    ...

On an instance, throw that exception

    $e->throw;

=method new

Construct a new exception

    my $e = CloudFlare::Client::Exception::Upstream::->new(
        message   => 'Bad things happened',
        errorcode => 'E_MAXAPI',
    );

=cut
