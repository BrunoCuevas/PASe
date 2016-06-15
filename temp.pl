use warnings;
use strict;
use GffDWM;
use pas2RDF;
# print "Prueba", "\n";
my @conditions1 = ['EXCOND0001'];
my @conditions2 = ['EXCOND0004'];
my @conditions3 = ['EXCOND0002'];
my @conditions4 = ['EXCOND0003'];
my %gffFileNameHash = (
	'excond0001.gff' => @conditions1	,
	'excond0004.gff' => @conditions2	,
	'excond0002.gff' => @conditions3	,
	'excond0003.gff' => @conditions4
);
my $instance = GffDWM -> new (
	'gffFileName' => \%gffFileNameHash,
	'webTemplateName' => 'htmlPolyATemplate.html'
);
#$instance -> loadGffContent;
# my $factory = pas2RDF -> new (
# 	'rdfFileOut' => 'x1.rdf'
# );
#$factory -> linkData($instance);
$instance -> loadWebTemplate;
$instance -> answerGffQuery('/pas/PAS01X29fa6')
#print $instance -> queryRDF('PAS01X29fa6'), "\n";
#$instance -> queryRDF('PASmmmmmmm');
#
# my @var = (sort keys %{$instance -> gffContent -> gffRows});
# print scalar @var, "\n";
# foreach my $key (@var) {
# 	print $key, ":", join("\t", @{$instance->gffContent->gffRows->{$key}->conditions}), "\n";
# }
