#!/usrl/bin/perl
#Date
#By Bruno Cuevas
#Final Project - Challenges Programming in Bioinformatics, 2015-2016.
#
# This class is used as a container of experimental conditions information
#
#
#
#
# ____________________________________________________________________________ #
package exCondRow;
	use Moose;
	use strict;
	use warnings;
	use Data::Dumper;
	has 'tag' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'description' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
# Don't write bellow this line
1;
