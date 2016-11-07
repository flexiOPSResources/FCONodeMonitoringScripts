#!/usr/bin/perl

# Set or read a node's MAC address

use strict;
use warnings;

use DBI;
use DBD::Pg;
use Getopt::Long;
use Data::Dumper;
use Time::Piece;

my $varfile = "/etc/extility/config/vars";
my %var;

my $dbh;
my $tdbh;

my $option_ip;
my $option_mac;
my $option_delete = 0;
my $option_add = 0;
my $option_list = 0;
my $option_verbose = 0;

my $file = {};
my $ipnode = {};
sub Syntax
{
    print STDERR "Usage: nodemac [options] NODEIP [MACADDRESS]\n\n";
    print STDERR "Options:\n\n";
    print STDERR "  -d, --delete           Delete a node's mac address(es)\n";
    print STDERR "  -a, --additional       Add (rather than replace) a MAC address\n";
    print STDERR "  -l, --list             List all IP and MAC address associations\n";
    print STDERR "  -v, --verbose          List verbosely all other node information\n";
    print STDERR "  -h, --help             Print this message\n";
    print STDERR "\n";
    print STDERR "Specify a MAC address to set the MAC address of a node, else print it to stdout\n";
    print STDERR "\n";
    return;   
}

sub ParseOptions
{
    if (!GetOptions (
             "help|h" => sub { Syntax(); exit(0); },
	     "delete|d" => \$option_delete,
	     "add|a" => \$option_add,
	     "list|l" => \$option_list,
	     "verbose|v+" => \$option_verbose
        ))
    {
        Syntax();
        die "Bad options";
    }

    if ($option_list?($#ARGV != -1):(($#ARGV < 0) || ($#ARGV>1)))
    {
	Syntax();
	die "Bad options";
    }
    $option_ip = shift (@ARGV);
    $option_mac = shift (@ARGV); # So undef if missing

    if (defined($option_mac))
    {
	# Put MAC address in canonical form
	$option_mac =~ s/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/$1:$2:$3:$4:$5:$6/g;
	$option_mac =~ tr/[A-Z]/[a-z]/;
	die ("Bad MAC address") unless ($option_mac=~ m/^([a-z0-9][a-z0-9]:){5}[a-z0-9][a-z0-9]$/);
    }

}

sub ReadVars
{
    open (VAR, $varfile) || die "Cannot open $varfile: $!";
    while(<VAR>)
    {
        chomp;
        if (/^\s*(export\s+)?(\w+)\s*=\s*"(.+)"\s*$/)
        {
            $var{$2}=$3;
        }
    }
    close(VAR);
}


sub OpenDatabase
{
    my $dbhost=$var{"XVP_DB_HOST"};
    my $dbname=$var{"XVP_DB_DBNAME"};
    my $dbuser=$var{"XVP_DB_USER"};
    my $dbpass=$var{"XVP_DB_PASSWORD"};
    $dbh = DBI->connect("dbi:Pg:database=$dbname;host=$dbhost", $dbuser, $dbpass);
    die "Cannot connect to xvpadmin database" unless defined ($dbh);

    $dbh->{mysql_auto_reconnect} =1;
    
    if ($option_verbose >1)
    {
	my $tdbhost=$var{"TL_DB_HOST"};
	my $tdbname=$var{"TL_DB_DBNAME"};
	my $tdbuser=$var{"TL_DB_USER"};
	my $tdbpass=$var{"TL_DB_PASSWORD"};
	$tdbh = DBI->connect("dbi:Pg:database=$tdbname;host=$tdbhost", $tdbuser, $tdbpass);
	die "Cannot connect to tigerlily database" unless defined ($tdbh);

	$tdbh->{mysql_auto_reconnect} =1;
    }

}

sub CloseDatabase
{
    $dbh->disconnect if defined($dbh);
    $tdbh->disconnect if defined($tdbh);
}

sub CheckNodeExists
{
    my $ip = shift @_;
    my $prep = $dbh->prepare(
	"SELECT * FROM node WHERE node.node_ip = ?");
    $prep->execute($ip) || die "Could not find nodes";
    die "Cannot find node $ip - add it using xvpadmin first." unless(defined($prep->fetchrow_hashref));
    $prep->finish || die "Could not find node";
}


sub DeleteMacAddress
{
    my $ip = shift @_;
    my $mac = shift @_;

    my $prep;

    if (defined($mac))
    {
	$mac =~ s/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/$1:$2:$3:$4:$5:$6/g;
	$mac =~ tr/[A-Z]/[a-z]/;
	$prep= $dbh->prepare(
	    "DELETE FROM node_mac USING node WHERE node.node_id = node_mac.node_id AND node_mac.mac_address = ? AND node.node_ip = ?");
	$prep->execute($mac, $ip) || die "Could delete MAC address";
    }
    else
    {
	$prep= $dbh->prepare(
	    "DELETE FROM node_mac USING node WHERE node.node_id = node_mac.node_id AND node.node_ip = ?");
	$prep->execute($ip) || die "Could delete MAC address";
    }

    $prep->finish || die "Could not delete MAC address";;
}

sub SetMacAddress
{
    my $ip = shift @_;
    my $mac = shift @_;

    # We could do an UPDATE here but we really want REPLACE. Deleting and reinstating is actually probably a good
    # idea anyway
    # "UPDATE node_mac SET mac_address = ? FROM node, node_mac WHERE node.node_id = node_mac.node_id AND node.node_ip = ?"
    if ($option_add)
    {
	DeleteMacAddress($ip, $mac);
    }
    else
    {
	DeleteMacAddress($ip);
    }

    my $prep= $dbh->prepare(
	"INSERT INTO node_mac (node_id, mac_address) VALUES ((SELECT node_id FROM node WHERE node.node_ip = ? ORDER BY node_id LIMIT 1), ?)");

    $prep->execute($ip, $mac) || die "Could set MAC address";
    $prep->finish || die "Could not set MAC address";
}

sub GetState
{
    my $s = shift @_;
    return "Not running" if ($s == 0);
    return "Running" if ($s == 1);
    return "Maintenance" if ($s == 2);
    return "Spare" if ($s == 3);
    return "Unknown ($s)";
}

sub GetNodeType
{
    my $t = shift @_;
    return "Undefined" unless (defined($t));
    return "Compute" if ($t==1);
    return "Router" if ($t==2);
    return "Unknown ($t)";
}


sub ReadMacAddress
{
    my $ip = shift @_;

    if ($option_verbose)
    {
	my $prepi = $dbh->prepare(
	"SELECT * FROM node WHERE node.node_ip = ?");
	$prepi->execute($ip) || die "Could not read MAC address";
	while (my $ref = $prepi->fetchrow_hashref)
	{
	    my $t = localtime;
	    $file = "/opt/extility/skyline/war/nodeload/".$$ref{'node_ip'}."."."csv";
	    open (CSVFILE, '>>',$file);
	    print CSVFILE  "$$ref{'node_ip'},";
	    print CSVFILE "$$ref{'curr_load'}";
	    print CSVFILE ",", $t->datetime ;
	    print CSVFILE "\n";
	    close (CSVFILE); 

#	    if ($option_verbose >1r
#	    {
#		my $prept = $tdbh->prepare(
#		    "SELECT * FROM cluster_nodes WHERE cluster_nodes.node_cluster_ref = ?");
#		$prept->execute($ip) || die "Could not read Tigerlily data";
#		
#		while (my $tref = $prept->fetchrow_hashref)
#		{
#		    # should only be one row as node_id is unique
#		    printf "  Tigerlily data\n";
#		    printf "    Node ID:              %d\n",$$tref{'node_id'};
#		    printf "    Cluster ID:           %d\n",$$tref{'cluster_id'};
#		    printf "    State:                %s\n",GetState($$tref{'node_state'});
##		    printf "    Available RAM:        %d MB\n",$$tref{'available_ram'};
#		    printf "    Base RAM:             %d MB\n",$$tref{'base_ram'};
#		    printf "    Free RAM:             %d MB\n",$$tref{'non_contention_free_ram'};
#		    printf "    RAM contention:       %.3f\n",$$tref{'ram_contention'};
##		    printf "    Available CPU cores:  %d\n",$$tref{'available_cpu'};
#		    printf "    CPU contention:       %.3f\n",$$tref{'contention_constant'};
#		    printf "    Load:                 %.3f\n",$$tref{'curr_load'};
#		}
#		$prept->finish || die "Could not read Tigerlily data";
#	    }
#
	}
	$prepi->finish || die "Could not read MAC address";
    }

    my $prep = $dbh->prepare(
	"SELECT * FROM node, node_mac WHERE node.node_id = node_mac.node_id AND node.node_ip = ?");
    $prep->execute($ip) || die "Could not read MAC address";
#    print "  MAC addresses for $ip:\n" if ($option_verbose);
#    while (my $ref = $prep->fetchrow_hashref)
#    {
##	if ($option_verbose)
#	{
##	    print "    ".$$ref{'mac_address'};
#	}
##	else
##	{
##	    print $$ref{'mac_address'}."\n";
#	}
#    }
#    print "\n" if ($option_verbose);

    $prep->finish || die "Could not read MAC address";
}

sub ListMacAddresses
{
    if ($option_verbose)
    {
	my $prep = $dbh->prepare(
	    "SELECT * FROM node");
	$prep->execute || die "Could not list MAC addresses";
	while (my $ref = $prep->fetchrow_hashref)
	{
	    next if ($$ref{'node_id'}==-1);
	    ReadMacAddress($$ref{'node_ip'});
	    #print "\n";
	}
	$prep->finish || die "Could not list MAC addresses";
    }
    else
    {
	my $prep = $dbh->prepare(
	    "SELECT * FROM node, node_mac WHERE node.node_id = node_mac.node_id");
	$prep->execute || die "Could not list MAC addresses";
	while (my $ref = $prep->fetchrow_hashref)
	{
#	    print $$ref{'node_ip'}." ".$$ref{'mac_address'}."\n";
	}

	$prep->finish || die "Could not list MAC addresses";
    }
}

ParseOptions;
ReadVars;
OpenDatabase;

if ($option_list)
{
    ListMacAddresses;
}
else
{
    CheckNodeExists($option_ip);

    if ($option_delete)
    {
	DeleteMacAddress($option_ip, $option_mac);
    }
    elsif (defined ($option_mac))
    {
	SetMacAddress($option_ip, $option_mac);
    }
    else
    {
	ReadMacAddress($option_ip);
    }
}
CloseDatabase;



