#!/usr/bin/perl

use warnings;
use strict;

my $conf_type;
my $resp;
my %resp_values;
my @matches;
my @config_content; 
my $vlan_response = 'yes';
my $result;

sub parse_config {
    my $config_template = shift;
    my %resp_values = %{$_[0]};
    $conf_type = $_[1];
    @config_content = split "\n", $config_template;
	print "\n## Auto Generated $conf_type Configuration ##\n\n";
    foreach my $line (@config_content) {
	    @matches = ($line =~ /<(\S+)>/g);
        for(@matches) {
    	    my $replace = $resp_values{$_};
            $line =~ s/<$_>/$replace/;
        }
        print "$line\n";
    }
}

my $ipsec_config_template = <<EOF;
set vpn ipsec esp-group espv1 compression '<compression>'
set vpn ipsec esp-group espv1 lifetime '<ttl>'
set vpn ipsec esp-group espv1 mode 'tunnel'
set vpn ipsec esp-group espv1 pfs 'disable'
set vpn ipsec esp-group espv1 proposal 1 encryption '<encryption_algorithm>'
set vpn ipsec esp-group espv1 proposal 1 hash '<encryption_hash>'
set vpn ipsec ike-group key1 lifetime '86400'
set vpn ipsec ike-group key1 proposal 1 dh-group '2'
set vpn ipsec ike-group key1 proposal 1 encryption '<encryption_algorithm>
set vpn ipsec ike-group key1 proposal 1 hash '<encryption_hash>'
set vpn ipsec ipsec-interfaces interface 'bond1'
set vpn ipsec ipsec-interfaces interface 'bond1v1'
set vpn ipsec site-to-site peer <remote_peer> authentication mode 'pre-shared-secret'
set vpn ipsec site-to-site peer <remote_peer> authentication pre-shared-secret '<secret_key>'
set vpn ipsec site-to-site peer <remote_peer> connection-type 'initiate'
set vpn ipsec site-to-site peer <remote_peer> default-esp-group 'espv1'
set vpn ipsec site-to-site peer <remote_peer> ike-group 'key1'
set vpn ipsec site-to-site peer <remote_peer> local-address '<local_address>'
set vpn ipsec site-to-site peer <remote_peer> tunnel 1 allow-nat-networks 'disable'
set vpn ipsec site-to-site peer <remote_peer> tunnel 1 allow-public-networks 'disable'
set vpn ipsec site-to-site peer <remote_peer> tunnel 1 local prefix '<local_prefix>'
set vpn ipsec site-to-site peer <remote_peer> tunnel 1 remote prefix '<remote_prefix>'
EOF

my $vlan_config_template = <<EOF;
set interfaces bonding <vif_interface> vif <vif_id> address '<vif_address>'
set interfaces bonding <vif_interface> vif <vif_id> vrrp vrrp-group <counter> advertise-interval '1'
set interfaces bonding <vif_interface> vif <vif_id> vrrp vrrp-group <counter> preempt 'false'
set interfaces bonding <vif_interface> vif <vif_id> vrrp vrrp-group <counter> priority '254'
set interfaces bonding <vif_interface> vif <vif_id> vrrp vrrp-group <counter> sync-group 'vgroup1'
set interfaces bonding <vif_interface> vif <vif_id> vrrp vrrp-group <counter> virtual-address '
EOF


print "\nxxxxx Vyatta Configuration Builder v.01 xxxxx\n\n";
print "Choose from the following options:\n";
print "1. IPSEC Configuration\n";
print "2. VLAN Configuration\n";
print "\nYour Choice: ";
chomp(my $mode = <STDIN>);
if( ($mode != 1) && ($mode != 2) ){
	die("Invalid selection");
}

if($mode == 1) {

    $conf_type = 'IPSEC';

    print "\n\nxxxxx IPSEC Tunnel Configuration xxxxx\n\n";
 
    # Capture Compression
    print "Compression [disable]: ";
    chomp($resp = <STDIN>);
    if($resp eq "") { $resp = 'disable'; }
    $resp_values{compression} = $resp;

    # Capture TTL
    print "Enter Time To Live [86400]: ";
    chomp($resp = <STDIN>);
    if($resp eq "") { $resp = '86400'; }
    $resp_values{ttl} = $resp;

    # Capture Encryption
    print "Encryption Algorithm: [aes256]: ";
    chomp($resp = <STDIN>);
    if($resp eq "") { $resp = 'aes256'; }
    $resp_values{encryption_algorithm} = $resp;

    # Capture Hash
    print "Encryption Hash [sha1]: ";
    chomp($resp = <STDIN>);
    if($resp eq "") { $resp = 'sha1'; }
    $resp_values{encryption_hash} = $resp;

    # Capture Encryption
    print "Preshared Secret Key: ";
    chomp($resp = <STDIN>);
    $resp_values{secret_key} = $resp;
 
    # Peer Address
    print "Remote Peer Address: ";
    chomp($resp = <STDIN>);
    $resp_values{remote_peer} = $resp;

    # Local Address
    print "Local Address: ";
    chomp($resp = <STDIN>);
    $resp_values{local_address} = $resp;

    # Local Prefix
    print "Local Address Prefix: ";
    chomp($resp = <STDIN>);
    $resp_values{local_prefix} = $resp;

    # Remote Prefix
    print "Remote Address Prefix: ";
    chomp($resp = <STDIN>);
    $resp_values{remote_prefix} = $resp;

    parse_config($ipsec_config_template, \%resp_values, $conf_type);
}
if($mode == 2) {
    
    my $counter = 0;

    while($vlan_response =~ /^y/) {
    
        $counter = $counter + 10;

        $conf_type = 'VLAN';

        # VLAN Type
        print "\nVLAN Type [public]: ";
        chomp($resp = <STDIN>);
        if($resp ne "private") {
    	    $resp = 'bond1'; 
        }
        else {
    	    $resp = 'bond0'
        }
        $resp_values{vif_interface} = $resp;
	
	    # VLAN ID
        print "VLAN ID: ";
        chomp($resp = <STDIN>);
        $resp_values{vif_id} = $resp;

        # VLAN Address
        print "VLAN Address: ";
        chomp($resp = <STDIN>);
        $resp_values{vif_address} = $resp;
   
        $resp_values{counter} = $counter;
        parse_config($vlan_config_template, \%resp_values, $conf_type);

        print "\nWould you like to add another VLAN [no]? ";
        chomp($vlan_response = <STDIN>);

        
    }

}