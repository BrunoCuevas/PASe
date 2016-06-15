#!/usr/bin/perl
#23rd March 2016
#By Bruno Cuevas

package GffRows;
	use Moose;
	use warnings;
	has 'seqid' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'source' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'type' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'start' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'end' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'score' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'strand' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'phase' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'attribute' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'conditions' => (
		'is' => 'rw',
		'isa' => 'ArrayRef[Str]',
		'required' => 0
	);
1;
