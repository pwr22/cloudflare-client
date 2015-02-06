package CloudFlare::Client;
# ABSTRACT: Object Orientated Interface to CloudFlare client API

# Or Kavorka will explode
use 5.014;
use strict; use warnings; no indirect 'fatal'; use namespace::autoclean;
use mro 'c3';

use Readonly;
use Moose; use MooseX::StrictConstructor;
use Types::Standard           'Str';
use CloudFlare::Client::Types 'LWPUserAgent';
use Kavorka;

use CloudFlare::Client::Exception::Connection;
use CloudFlare::Client::Exception::Upstream;
use LWP::UserAgent       6.02;
# This isn't used directly but we want the dependency
use LWP::Protocol::https 6.02;
use JSON::MaybeXS;

our $VERSION = '0.05_3'; # TRIAL VERSION

# CF credentials
has '_user' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    init_arg => 'user');
has '_key' => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    init_arg => 'apikey');

Readonly my $UA_STRING => "CloudFlare::Client/$CloudFlare::Client::VERSION";
sub _buildUa {
    Readonly my $ua => LWP::UserAgent::->new;
    $ua->agent($UA_STRING);
    return $ua}
has '_ua' => (
    is       => 'ro',
    isa      => LWPUserAgent,
    init_arg => undef,
    builder  => '_buildUa');

# Calls through to the CF API, can throw exceptions under ::Exception::
Readonly my $CF_URL =>
    'https://www.cloudflare.com/api_json.html';
method _apiCall($act is ro, %args is ro) {
    # query cloudflare
    Readonly my $res => $self->_ua->post($CF_URL, {
        %args,
        # global args
        # override user specified
        tkn   => $self->_key,
        email => $self->_user,
        a     => $act});
    # Handle connection errors
    CloudFlare::Client::Exception::Connection::->throw(
        status  => $res->status_line,
        message => 'HTTPS request failed')
        unless $res->is_success;
    # Handle errors from CF
    Readonly my $info => decode_json($res->decoded_content);
    CloudFlare::Client::Exception::Upstream::->throw(
        errorCode => $info->{err_code},
        message   => $info->{msg})
        unless $info->{result} eq 'success';

    return $info->{response}}

# Methods
method stats($zone  is ro, $itrvl is ro) {
    return $self->_apiCall('stats', z => $zone, interval => $itrvl)}

method zoneLoadMulti () {
    return $self->_apiCall('zone_load_multi')}

method recLoadAll($zone is ro) {
    return $self->_apiCall('rec_load_all', z => $zone)}

# Requires at least one zone, but can take any number
method zoneCheck($fZone is ro, @rZones is ro) {
    return $self->_apiCall('zone_check', zones => join ',', $fZone, @rZones)}

method zoneIps($zone is ro, %args is ro) {
    return $self->_apiCall('zone_ips', %args,
                           # Override user specified
                           z     => $zone)}

method ipLkup($ip is ro) {
    return $self->_apiCall('ip_lkup', ip => $ip)}

method zoneSettings($zone is ro) {
    return $self->_apiCall('zone_settings', z => $zone)}

method secLvl($zone is ro, $secLvl is ro) {
    return $self->_apiCall('sec_lvl', z => $zone, v => $secLvl);
}

method cacheLvl($zone is ro, $cchLvl is ro) {
    return $self->_apiCall('cache_lvl', z => $zone, v => $cchLvl)}

method devMode($zone is ro, $val is ro) {
    return $self->_apiCall('devmode', z => $zone, v => $val)}

method fpurgeTs($zone is ro, $val is ro) {
    return $self->_apiCall('fpurge_ts', z => $zone, v => $val)}

method zoneFilePurge($zone is ro, $url is ro) {
    return $self->_apiCall('zone_file_purge', z => $zone, url => $url)}

method zoneGrab($zId is ro) {
    return $self->_apiCall('zone_grab', zid => $zId)}

method _wlBanNul($act is ro, $ip is ro) {
    return $self->_apiCall($act, key => $ip)}

method wl($ip is ro) {
    return $self->_wlBanNul('wl', $ip)}

method ban($ip is ro) {
    return $self->_wlBanNul('ban', $ip)}

method nul($ip is ro) {
    return $self->_wlBanNul('nul', $ip)}

method ipv46($zone is ro, $val is ro) {
    return $self->_apiCall('ipv46', z => $zone, v => $val)}

method async($zone is ro, $val is ro) {
    return $self->_apiCall('async', z => $zone, v => $val)}

method minify($zone is ro, $val is ro) {
    return $self->_apiCall('async', z => $zone, v => $val)}

method mirage2($zone is ro, $val is ro) {
    return $self->_apiCall('mirage2', z => $zone, v => $val)}

method recNew($zone is ro, $type is ro, $name is ro, $cntnt is ro,
              $ttl is ro, %args is ro) {
    return $self->_apiCall('rec_new',
                           %args,
                           # Override user specified
                           z => $zone, type => $type, name => $name,
                           content => $cntnt, ttl => $ttl)}

method recEdit($zone is ro, $type is ro, $id is ro, $name is ro, $cntnt is ro,
               $ttl is ro, %args  is ro) {
    return $self->_apiCall('rec_edit',
                           %args,
                           # override user specified
                           z => $zone, type => $type, id => $id, name => $name,
                           content => $cntnt, ttl => $ttl)}

method recDelete($zone is ro, $id is ro) {
    return $self->_apiCall('rec_delete', z => $zone, id => $id)}

__PACKAGE__->meta->make_immutable;
1; # End of CloudFlare::Client

__END__

=pod

=encoding UTF-8

=head1 NAME

CloudFlare::Client - Object Orientated Interface to CloudFlare client API

=head1 VERSION

version 0.05_3

=head1 SYNOPSIS

    use CloudFlare::Client;

    my $api = CloudFlare::Client::->new(
        user   => $CF_USER,
        apikey => $CF_KEY);
    $api->stats;
    ...

=head1 OVERVIEW

Please see the documentation at
L<https://www.cloudflare.com/docs/client-api.html> for information on the
CloudFlare client API and its arguments. Optional arguments are passed in as a
hash with keys as given in the docs

Successful API calls return the response section from the upstream JSON
API. Failures for whatever reason throw exceptions under the
CloudFlare::Client::Exception:: namespace

=head1 METHODS

=head2 new

Construct a new API object

    my $api = CloudFlare::Client::->new(
        user   => $CF_USER,
        apikey => $CF_KEY)

=head2 stats

    $api->stats($zone, $interval)

=head2 zoneLoadMulti

    $api->zoneLoadMulti

=head2 recLoadAll

    $api->recLoadAll($zone);

=head2 zoneCheck

    $api->zoneCheck(@zones);

=head2 zoneIps

    $api->zoneIps($zone, %optionalArgs);

=head2 ipLkup

    $api->ipLkup($ip)

=head2 zoneSettings

    $api->zoneSettings($zone)

=head2 secLvl

    $api->secLvl($zone, $securityLvl)

=head2 cacheLvl

    $api->cacheLvl($zone, $cacheLevel)

=head2 devMode

    $api->devMode($zone, $value)

=head2 fpurgeTs

    $api->fpurgeTs($zone, $value)

=head2 zoneFilePurge

    $api->zoneFilePurge($zone, $url)

=head2 zoneGrab

    $api->zoneGrab($zoneId)

=head2 wl

    $api->wl($ip)

=head2 ban

    $api->ban($ip)

=head2 nul

    $api->nul($ip)

=head2 ipv46

    $api->ipv46($zone, $value)

=head2 async

    $api->async($zone, $value)

=head2 minify

    $api->minify($zone, $value)

=head2 mirage2

    $api->mirage2($zone, $value)

=head2 recNew

    $api->recNew($zone, $type, $name
                 $content, $ttl, %optionalArgs)

=head2 recEdit

    $api->recEdit($zone, $type, $recordId, $name
                  $content, $ttl, %optionalArgs)

=head2 recDelete

    $api->recDelete($zone, $recordId)

=for test_synopsis my ($CF_USER, $CF_KEY);

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<Mojo::Cloudflare|Mojo::Cloudflare>

=item *

L<WebService::CloudFlare::Host|WebService::CloudFlare::Host>

=back

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc CloudFlare::Client

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

MetaCPAN

A modern, open-source CPAN search engine, useful to view POD in HTML format.

L<http://metacpan.org/release/CloudFlare-Client>

=back

=head2 Email

You can email the author of this module at C<me+dev@peter-r.co.uk> asking for help with any problems you have.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<https://github.com/pwr22/cloudflare-client>

  git clone git://github.com/pwr22/cloudflare-client.git

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/pwr22/cloudflare-client/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 ACKNOWLEDGEMENTS

Thanks to CloudFlare providing an awesome free service with an API.

=head1 AUTHOR

Peter Roberts <me+dev@peter-r.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2015 by Peter Roberts.

This is free software, licensed under:

  The MIT (X11) License

=cut
