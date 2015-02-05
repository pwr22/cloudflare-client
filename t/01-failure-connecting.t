#!perl -T

# This file aims to test the failure of all API calls when a
# connection cannot be made
package CloudFlare::Client::Test;

use strict; use warnings;
use mro 'c3';
use IO qw(Handle File Dir);
use autodie ':all'; no indirect 'fatal';
use namespace::autoclean;

use namespace::autoclean;
use Readonly;
use Try::Tiny;
use Moose; use MooseX::StrictConstructor;

use Test::More;
use Test::Exception;
use Test::LWP::UserAgent;

plan tests => 33;

extends 'CloudFlare::Client';

# Override the real user agent with a mocked one
# It will always fail to connect
sub _buildUa { Test::LWP::UserAgent::->new }
__PACKAGE__->meta->make_immutable;

# Test upstream failures
# Catch potential failure
Readonly my $API => try {
    CloudFlare::Client::Test::->new( user => 'user', apikey  => 'KEY')}
    catch { diag $_ };
# Valid values
Readonly my $ZONE         => 'zone.co.uk';
Readonly my $ITRVL        => 20;
Readonly my $HOURS        => 48;
Readonly my $REC_CLASS    => 'r';
Readonly my $GEO          => 1;
Readonly my $IP           => '0.0.0.0';
Readonly my $SEC_LVL      => 'med';
Readonly my $CCH_LVL      => 'agg';
Readonly my $DEV_MODE     => 1;
Readonly my $PRG_CCH      => 1;
Readonly my $PRG_URL      => "http://$ZONE/file.txt";
Readonly my $ZONE_ID      => 1;
Readonly my $IP_VAL       => 0;
Readonly my $MINI_VAL     => 'a';
Readonly my $MIR_VAL      => 0;
Readonly my $REC_NAME     => 'hostname';
Readonly my $TTL          => 1;
Readonly my $PRIO         => 10;
Readonly my $SRVC         => 'dunno';
Readonly my $SRVC_NAME     => 'dunno';
Readonly my $PROTO        => '_tcp';
Readonly my $WGHT         => 10;
Readonly my $PORT         => 8080;
Readonly my $TRGT         => 'dunno';
Readonly my $IP6          => '::1';
Readonly my $REC_ID       => 1;
# method => [[ args1 ], ...]
Readonly my %tstSpec => (
    stats         => [[ $ZONE, $ITRVL ]],
    zoneLoadMulti => [[]],
    recLoadAll    => [[ $ZONE ]],
    zoneCheck     => [[ $ZONE ], [ $ZONE, $ZONE ]],
    zoneIps       => [[ $ZONE ],
                      [ $ZONE, hours => $HOURS ],
                      [ $ZONE, class => $REC_CLASS ],
                      [ $ZONE, geo => $GEO ]],
    ipLkup        => [[ $IP ]],
    zoneSettings  => [[ $ZONE ]],
    secLvl        => [[ $ZONE, $SEC_LVL ]],
    cacheLvl      => [[ $ZONE, $CCH_LVL ]],
    devMode       => [[ $ZONE, $DEV_MODE ]],
    fpurgeTs      => [[ $ZONE, $PRG_CCH ]],
    zoneFilePurge => [[ $ZONE, $PRG_URL ]],
    zoneGrab      => [[ $ZONE_ID ]],
    wl            => [[ $IP ]],
    ban           => [[ $IP ]],
    nul           => [[ $IP ]],
    ipv46         => [[ $ZONE, $IP_VAL ]],
    async         => [[ $ZONE, $MINI_VAL ]],
    mirage2       => [[ $ZONE, $MIR_VAL ]],
    recNew        => [[ $ZONE, 'A', $REC_NAME, $IP, $TTL ],
                      [ $ZONE, 'CNAME', $REC_NAME, $ZONE, $TTL ],
                      [ $ZONE, 'MX', $REC_NAME, $ZONE, $TTL,
                        prio => $PRIO ],
                      [ $ZONE, 'TXT', $REC_NAME, $ZONE, $TTL ],
                      [ $ZONE, 'SPF', $REC_NAME, $ZONE, $TTL ],
                      [ $ZONE, 'AAAA', $REC_NAME, $IP6, $TTL ],
                      [ $ZONE, 'NS', $REC_NAME, $IP, $TTL ],
                      [ $ZONE, 'SRV', $REC_NAME, $IP, $TTL,
                        prio => $PRIO,
                        srvname => $SRVC_NAME,
                        protocol => $PROTO,
                        weight => $WGHT,
                        port => $PORT,
                        target => $TRGT ],
                      [ $ZONE, 'LOC', $REC_NAME, $IP, $TTL ]],
    recDelete     => [[ $ZONE, $REC_ID ]]);
# Test connection failures
for my $method ( sort keys %tstSpec ) {
    for my $args (@{ $tstSpec{$method} }) {
        throws_ok { $API->$method(@$args) }
                  'CloudFlare::Client::Exception::Connection',
                  "$method dies with a connection error"}}
