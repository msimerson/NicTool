##########
#
# NicTool v2.09 Copyright 2011 The Network People, Inc.
#
# NicTool is free software; you can redistribute it and/or modify it under
# the terms of the Affero General Public License as published by Affero,
# Inc.; either version 1 of the License, or any later version.
#
# NicTool is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the Affero GPL for details.
#
# You should have received a copy of the Affero General Public License
# along with this program; if not, write to Affero Inc., 521 Third St,
# Suite 225, San Francisco, CA 94107, USA
#
##########
use strict;
use warnings;

use lib ".";
use lib "t";
use TestConfig;
use TestSupport;
use Test::More;
$Data::Dumper::Sortkeys=1;

BEGIN { plan 'no_plan'  }

use_ok( 'NicTool' );
use_ok( 'NicToolServer' );
use_ok( 'NicToolServer::Export' );

my $nts = NicToolServer->new();
no warnings;
$NicToolServer::db_user = Config('db_user');
$NicToolServer::db_pass = Config('db_pass');
use warnings;

my $dbh = NicToolServer->dbh( Config('dsn') );
ok( $dbh, 'dbh handle' );
isa_ok( $dbh, 'DBI::db' );
$nts = NicToolServer->new(undef,undef,$dbh);

my $nt = new NicTool(
    cache_users  => 0,
    cache_groups => 0,
    server_host  => Config('server_host'),
    server_port  => Config('server_port')
);
ok( $nt, 'nictool connection' );
die "Couldn't connect to NicToolServer" unless ok( ref $nt, 'NicTool' );


my $nt_user = $nt->login(
    username => Config('username'),
    password => Config('password'),
);
ok( $nt_user, 'nictool login' );
die "Couldn't log in" unless ok( !$nt_user->result->is_error, "error-free login" );
die "Couldn't log in" unless ok( $nt_user->nt_user_session, "login session" );


my $export = NicToolServer::Export->new( $nts, 1 );
#warn Data::Dumper::Dumper($export);

my $nsid = $export->get_ns_id(id=>1);
my $logid = $export->get_log_id( success=>1 ); # create a NT export log entry
undef $export->{log_id};
$logid = $export->get_log_id( success=>1,partial=>1 );

my $r = $export->export( ns_id=> $nsid );
ok( $r, "export ($nsid)");

$r = $export->get_last_ns_export( ns_id=> $nsid );
ok( $r, "get_last_ns_export, $nsid");
#warn Data::Dumper::Dumper($r);

$r = $export->get_last_ns_export( ns_id=> $nsid, success=>1 );
ok( $r, "get_last_ns_export, $nsid, success");
#warn Data::Dumper::Dumper($r);

$r = $export->get_last_ns_export( ns_id=> $nsid, success=>1, partial=>1 );
ok( $r, "get_last_ns_export, $nsid, success, partial");
#warn Data::Dumper::Dumper($r);

#$r = $export->get_zone_list( ns_id=> 0 );
#$r = $export->get_zone_list( ns_id=> $nsid );
#ok( $r, "export ($nsid), ".scalar @$r." zones");
#warn Data::Dumper::Dumper($r);
#exit;

#warn Data::Dumper::Dumper($r);
