#!/usr/bin/perl
use strict;
use warnings;
use GffDWM ;
use exCondDWM;
use pas2RDF;
print "Content-Type: text/html\n\n";
my @conditions1 = ['EXCOND0001'];
my @conditions2 = ['EXCOND0004'];
my @conditions3 = ['EXCOND0002'];
my @conditions4 = ['EXCOND0003'];
my %gffFileNameHash = (
	'WT-CM-X_polyA.gff' => @conditions1	,
	'WT--C-X_polyA.gff' => @conditions2	,
	'WT-MM-X_polyA.gff' => @conditions3	,
	'WT--N-X_polyA.gff' => @conditions4
);
my $gffDynamicWebMaker = GffDWM -> new (
	'gffFileName' => \%gffFileNameHash,
	'webTemplateName' => 'html_polya_template.html'
);
my $exit1 = $gffDynamicWebMaker -> loadGffContent;
# my $exit2 = $gffDynamicWebMaker -> loadWebTemplate;
# my $exit3 = $gffDynamicWebMaker -> answerGffQuery($ENV{PATH_INFO});
my $factory = pas2RDF -> new (
	'rdfFileOut' => 'fileout.rdf'
);
foreach my $row (sort keys %{$gffDynamicWebMaker -> gffContent -> gffRows}) {
	$factory -> linkDataToEnsmbl($row, $gffDynamicWebMaker -> gffContent -> gffRows ->{$row});
	$factory -> linkDataToConditions($row, $gffDynamicWebMaker -> gffContent -> gffRows -> {$row});
}
# my $exCondDynamicWebMaker = exCondDWM -> new (
# 	'exCondFileName' => 'conditions_table.txt',
# 	'webTemplateName' => 'html_excondition.html'
# );
# my $exit4 = $exCondDynamicWebMaker -> loadExCondContent;
# my $exit5 = $exCondDynamicWebMaker -> loadWebTemplate;
# my $exit6 = $exCondDynamicWebMaker -> answerGffQuery($ENV{PATH_INFO});
# print $exCondDynamicWebMaker -> makeExCondWebContent('EXCOND0004'), "\n";
