package CloudFlare::Client;
# ABSTRACT: Object Orientated Interface to CloudFlare client API

# Or Kavorka will explode
use 5.014;
use strict; use warnings;
use mro 'c3';
use IO qw(Handle File Dir);
use autodie ':all'; no indirect 'fatal';
use namespace::autoclean;

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

# VERSION

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

=for test_synopsis
my ($CF_USER, $CF_KEY);

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

=method new

Construct a new API object

    my $api = CloudFlare::Client::->new(
        user   => $CF_USER,
        apikey => $CF_KEY)

=method stats

    $api->stats($zone, $interval)

=method zoneLoadMulti

    $api->zoneLoadMulti

=method recLoadAll

    $api->recLoadAll($zone);

=method zoneCheck

    $api->zoneCheck(@zones);

=method zoneIps

    $api->zoneIps($zone, %optionalArgs);

=method ipLkup

    $api->ipLkup($ip)

=method zoneSettings

    $api->zoneSettings($zone)

=method secLvl

    $api->secLvl($zone, $securityLvl)

=method cacheLvl

    $api->cacheLvl($zone, $cacheLevel)

=method devMode

    $api->devMode($zone, $value)

=method fpurgeTs

    $api->fpurgeTs($zone, $value)

=method zoneFilePurge

    $api->zoneFilePurge($zone, $url)

=method zoneGrab

    $api->zoneGrab($zoneId)

=method wl

    $api->wl($ip)

=method ban

    $api->ban($ip)

=method nul

    $api->nul($ip)

=method ipv46

    $api->ipv46($zone, $value)

=method async

    $api->async($zone, $value)

=method minify

    $api->minify($zone, $value)

=method mirage2

    $api->mirage2($zone, $value)

=method recNew

    $api->recNew($zone, $type, $name
                 $content, $ttl, %optionalArgs)

=method recEdit

    $api->recEdit($zone, $type, $recordId, $name
                  $content, $ttl, %optionalArgs)

=method recDelete

    $api->recDelete($zone, $recordId)

=head1 SEE ALSO

Mojo::Cloudflare
WebService::CloudFlare::Host

=head1 ACKNOWLEDGEMENTS

Thanks to CloudFlare providing an awesome free service with an API.

=cut
