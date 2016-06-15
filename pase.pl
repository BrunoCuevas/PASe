#!/usrl/bin/perl
#Date
#By Bruno Cuevas
#Final Project - Challenges Programming in Bioinformatics, 2015-2016.
#
# Descripción
#	This script will enable the user to perform queries in genes,
#	coordinates, and experimental conditions
#
#
# _____________________________________________________________________________#
use strict;
use warnings;
use GffDWM;
use exCondDWM;
use geneDWM;


my %trialPath = (
	'path' => '/browser/gen/MGG_02924'
);
if (my $path = $trialPath{path}) {
	my @gffFiles = `ls *.gff` or die "ERROR 1 : No files\n";
	chomp @gffFiles;
	my %gffFilesHash;
	foreach my $currentFile (@gffFiles) {
		$currentFile =~ /exCond(\d{4})/i;
		$gffFilesHash{$currentFile} = [$1];
	}
	my $gffInstance = GffDWM -> new (
		'gffFileName' => \%gffFilesHash,
		'webTemplateName' => 'html_polya_template.html'
	);
	my $exCondInstance = exCondDWM -> new (
		'exCondFileName' => 'conditions_table.txt',
		'webTemplateName' => 'html_excondition.html'
	);
	my $geneDWMInstance = geneDWM -> new (
		'webTemplateName' => 'geneTemplate.html',
	);
	my ($blank, $browser, $identifier) = split("/", $path);
	if ($browser eq 'rest') {
		if ($identifier eq '') {
			print "Content-Type: text/html\n\n";
			my $webTemplateRestBrowserFileName = 'wTRBF.html';
			if (open(WEBFILE, $webTemplateRestBrowserFileName)) {
				my @web = <WEBFILE>;
				close (WEBFILE);
				my $file = join("", @web);
				print $file, "\n";
			}
		} else {
			my @restKeys = ('id', 'gene', 'format', 'excond');
			my %queryTerms;
			foreach my $currentRestKey (@restKeys) {
				if ($identifier =~ m/$currentRestKey\=(\w*)\;/) {
					$queryTerms{$currentRestKey} = $1;
				} else {
					next;
				}
			}
			if (scalar (keys %queryTerms) gt 1) {
				use RDF::Trine;
				use RDF::Query;
				use RDF::Query::Client;
				foreach my $currentQueryTerm (keys %queryTerms) {

					my $query =
					"
					PREFIX local:<localhost:9999/blazegraph/namespace/pase/sparql>
					SELECT ?o
					WHERE {

					}
					";

				}
			}
		}
	} elsif ($browser eq 'browser') {
		if ($identifier eq '') {

		} else {
			my ($blank, $browser, $identifier, $query) = split("/", $path);
			print "B = ", $browser, " I = ", $identifier, " Q = ", $query, "\n";
			if ($identifier eq 'pas') {
				$gffInstance -> loadGffContent;
				my $exit1 = $gffInstance -> loadWebTemplate;
				my $queryGff = '/'.$identifier.'/'.$query;
				$gffInstance -> answerGffQuery($queryGff);
			} elsif ($identifier eq 'gen') {
				$geneDWMInstance -> loadWebTemplate;
				my $queryGene = '/'.$identifier.'/'.$query;
				$geneDWMInstance -> answerGeneQuery($queryGene);

			} elsif ($identifier eq 'exc') {
				$exCondInstance -> loadExCondContent;
				$exCondInstance -> loadWebTemplate;
				my $queryExCond = '/'.$identifier.'/'.$query;
				$exCondInstance -> answerExCondQuery ($queryExCond) ;
			} else {
				print "Error, not found\n";
			}
		}
	}

} else {
	die "No environment path variable\n";
}
