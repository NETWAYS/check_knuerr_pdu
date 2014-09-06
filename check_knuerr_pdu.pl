#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
# check_knuerr_pdu.pl - checks the knuerr_pdu environmental devices.
# Copyright (C) 2009  NETWAYS GmbH, www.netways.de
# Author: Michael Streb <michael.streb@netways.de>
# Version: $Id: c81515ab36aa976b4ff8540841e9fd8ed35735bf $
#
# This program is free software; you can redistribute it and/or
# modify it under the tepdu of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# $Id: c81515ab36aa976b4ff8540841e9fd8ed35735bf $
# ------------------------------------------------------------------------------

# basic requirements
use strict;
use Getopt::Long;
use File::Basename;
use Pod::Usage;
use Net::SNMP;

# predeclared subs
use subs qw/print_help/;

# predeclared vars
use vars qw (
  $PROGNAME
  $VERSION

  %states
  %state_names

  $opt_host
  $opt_community
  $opt_module
  $opt_warning
  $opt_critical

  $opt_help
  $opt_man
  $opt_verbose
  $opt_version

  $module

  $output
);

# Main values
$PROGNAME = basename($0);
$VERSION  = '1.1';

# Nagios exit states
%states = (
	OK       => 0,
	WARNING  => 1,
	CRITICAL => 2,
	UNKNOWN  => 3
);

# Nagios state names
%state_names = (
	0 => 'OK',
	1 => 'WARNING',
	2 => 'CRITICAL',
	3 => 'UNKNOWN'
);

$opt_warning = "null";
$opt_critical = "null";

# SNMP

my $opt_community = "public";
my $snmp_version  = "2c";

my $response;

# Get the options from cl
Getopt::Long::Configure('bundling');
GetOptions(
	'h'       => \$opt_help,
	'H=s'     => \$opt_host,
	'C=s',    => \$opt_community,
	'M=n',    => \$opt_module,
	'w=s'     => \$opt_warning,
	'c=s'     => \$opt_critical,
	'man'     => \$opt_man,
	'verbose' => \$opt_verbose,
	'V'		  => \$opt_version
  )
  || print_help( 1, 'Please check your options!' );

# If somebody wants to the help ...
if ($opt_help) {
	print_help(1);
}
elsif ($opt_man) {
	print_help(99);
}
elsif ($opt_version) {
	print_help(-1);
}

# oids
my $module_value	= ".1.3.6.1.4.1.2769.1.1.3.".$opt_module.".1.1.0";

# Check if all needed options present.
unless ( $opt_host && $opt_module ) {

	print_help( 1, 'Not enough options specified!' );
}
else {

	# Open SNMP Session
	my ( $session, $error ) = Net::SNMP->session(
		-hostname  => $opt_host,
		-community => $opt_community,
		-port      => 161,
		-version   => $snmp_version
	);

	# SNMP Session failed
	if ( !defined($session) ) {
		print $state_names{ ( $states{UNKNOWN} ) } . ": $error";
		exit $states{UNKNOWN};
	}

	# get the modules value
	my $response = $session->get_request($module_value);
	if ($response->{$module_value} =~ m/(\d+)/ ) {
		$module_value = $response->{$module_value}/10;
	} else {
		print "No value found on module $opt_module\n";
		exit ( $states{UNKNOWN} );
	}

	#close SNMP
	$session->close();
	
	# set the properties for installed input module
	if ($opt_critical =~ m/(\d+)/ && $module_value >= $opt_critical) {
		print "CRITICAL: module $opt_module is at $module_value amp|value${opt_module}=${module_value}A\n";
		exit ( $states{CRITICAL} );
	} else {
		if ($opt_warning =~ m/(\d+)/ && $module_value >= $opt_warning) {
			print "WARNING: module $opt_module is at $module_value amp|value${opt_module}=${module_value}A\n";
			exit ( $states{WARNING} );
		} else {
			print "OK: module $opt_module is at $module_value amp|value${opt_module}=${module_value}A\n";
			exit ( $states{OK} );
		}
	}
}	

# -------------------------
# THE SUBS:
# -------------------------


# print_help($level, $msg);
# prints some message and the POD DOC
sub print_help {
	my ( $level, $msg ) = @_;
	$level = 0 unless ($level);
	if($level == -1) {
		print "$PROGNAME - Version: $VERSION\n";
		exit ( $states{UNKNOWN});
	}
	pod2usage(
		{
			-message => $msg,
			-verbose => $level
		}
	);

	exit( $states{UNKNOWN} );
}

1;

__END__

=head1 NAME

check_knuerr_pdu.pl - Checks the knuerr_pdu environmental devies for NAGIOS.

=head1 SYNOPSIS

check_knuerr_pdu.pl -h

check_knuerr_pdu.pl --man

check_knuerr_pdu.pl -H <host> -M <module> [-w <warning>] [-c <critical>]

=head1 DESCRIPTION

B<check_knuerr_pdu.pl> recieves the data from the knuerr_pdu devices. It can check thresholds of 
the modules.

=head1 OPTIONS

=over 8

=item B<-h>

Display this helpmessage.

=item B<-H>

The hostname or ipaddress of the knuerr_pdu device.

=item B<-C>

The snmp community of the knuerr_pdu device.

=item B<-M>

The module to check

=item B<-w>

The warning threshold. 

=item B<-c>

The critical threshold. 

=item B<--man>

Displays the complete perldoc manpage.

=back

=cut

=head1 THRESHOLD FORMATS

B<1.> start <= end

Thresholds have to be specified from the lower level end on e.g. -w 20 is meaning that a
warning error is occuring when the collected value is over 20.

=head1 VERSION

$Id: c81515ab36aa976b4ff8540841e9fd8ed35735bf $

=head1 AUTHOR

NETWAYS GmbH, 2005, http://www.netways.de.

Written by Michael Streb <michael.streb@netways.de>.

Please report bugs through the contact of Nagios Exchange, http://www.nagiosexchange.org. 

