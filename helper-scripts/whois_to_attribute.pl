#!/usr/bin/perl

use strict;
use warnings;

my %object = (
	'AsBlock' => 'as-block',
	'AsSet' => 'as-set',
	'AutNum' => 'aut-num',
	'Domain' => 'domain',
	'FilterSet' => 'filter-set',
	'Inet6Num' => 'inet6num',
	'InetNum' => 'inetnum',
	'InetRtr' => 'inet-rtr',
	'Irt' => 'irt',
	'KeyCert' => 'key-cert',
	'Limerick' => 'limerick',
	'Mntner' => 'mntner',
	'Organisation' => 'organisation',
	'PeeringSet' => 'peering-set',
	'Person' => 'person',
	'Poem' => 'poem',
	'PoeticForm' => 'poetic-form',
	'Response' => 'response',
	'Role' => 'role',
	'Route' => 'route',
	'Route6' => 'route6',
	'RouteSet' => 'route-set',
	'RtrSet' => 'rtr-set',
);

print "STEP 0\n";
my $target = $ARGV[0];

exit 0	if $target eq 'Information';
exit 0	if $target eq 'Response';
exit 0	if $target eq 'Limerick';

my @whois_data = `whois -t $object{$target}`;
my (@mandatories, @optionals, @singles, @multiples);

print "STEP 1\n";
for my $line (@whois_data) {
	if ($line =~ /(.*?):\s+\[(.*?)\]\s+\[(.*?)\]\s+\[(.*?)\]/) {
		my $attribute_name = lc $1;
		my $mandatory      = lc $2;
		my $cardinality    = lc $3;
		$attribute_name =~ s/-/_/g;

		if ($mandatory eq 'mandatory') {
			push @mandatories, $attribute_name;
		} elsif ($mandatory =~ /optional|generated/) {
			push @optionals, $attribute_name;
		} else {
			die "Optional or mandatory ?\n$line";
		}

		if ($cardinality eq 'single') {
			push @singles, $attribute_name;
		} elsif ($cardinality eq 'multiple') {
			push @multiples, $attribute_name;
		} else {
			die "single or multiple ?\n$line";
		}
	}
}
print "STEP 3\n";

my $mandatories = join ', ', map { "'$_'"} @mandatories;
my $optionals   = join ', ', map { "'$_'"} @optionals;
my $singles     = join ', ', map { "'$_'"} @singles;
my $multiples   = join ', ', map { "'$_'"} @multiples;
my $key         = "'$object{$target}'";
$key            =~ s/-/_/g;
print "STEP 4\n";

print "#######################################################################################\n";
print "# The following lines where auto-generated by 'perl whois_to_attribute.pl $target'\n\n";

print map { "# $_"} @whois_data;

print "__PACKAGE__->attributes( 'primary',     [ $key ] );\n";
print "__PACKAGE__->attributes( 'mandatory',   [ $mandatories ] );\n";
print "__PACKAGE__->attributes( 'optional',    [ $optionals ] );\n";
print "__PACKAGE__->attributes( 'single',      [ $singles ] );\n";
print "__PACKAGE__->attributes( 'multiple',    [ $multiples ] );\n";

print "\n# End of auto-generated lines\n";
print "#######################################################################################\n";

