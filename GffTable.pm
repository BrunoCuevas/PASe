#!/usr/bin/perl
#23rd March 2016
#By Bruno Cuevas

package GffTable;
	use Moose;
	use warnings;
	use GffRows;
	use Bio::Seq;
	use Bio::SeqIO;
	has 'gffRows' => (
		'is' => 'rw',
		'isa' => 'HashRef[GffRows]',
		'required' => 0
	);
1;
