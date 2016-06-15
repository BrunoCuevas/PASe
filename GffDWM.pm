#!/usrl/bin/perl
#Date
#By Bruno Cuevas
#Final Project - Challenges Programming in Bioinformatics, 2015-2016.
#
# This class will be used as RDF file parser and as dynamic web content
#	maker
#
#
#
# ____________________________________________________________________________ #
package GffDWM;
	use Moose	;
	use strict	;
	use warnings;
	use GffTable;
	use GffRows;
	use Data::Dumper;
	use RDF::Trine;
	use RDF::Query;
	use RDF::Trine::Model;
	use RDF::Query::Client;
	use LWP::Simple;
	use Bio::SeqIO;
	use Bio::Seq;
	has 'gffFileName' => (
		'is' => 'rw',
		'isa' => 'HashRef',
		'required' => 0
	);
	has 'gffContent' => (
		'is' => 'rw',
		'isa' => 'GffTable',
		'required' => 0
	);
	has 'webTemplateName' => (
		'is' => 'rw',
		'isa' => 'Str',
		'required' => 0
	);
	has 'webTemplate' => (
		'is' => 'rw',
		'isa' => 'Str',
		'required' => 0
	);


	sub loadGffContent {
	#
	#	loadGffContent : loads a GFF file into memory for future queries
	#
	#
	#
		if (@_) {
			my ($self) = @_ ;
			if (%{$self -> gffFileName}){
				my %tempGffHash;
				foreach my $filePath (sort keys %{$self->gffFileName}) {
					if (open(GFF, $filePath)) {
						#print "File succesfully opened!\n";
						my @gffFile = <GFF>;
						chomp(@gffFile);
						my $tempConditionsRef = $self->gffFileName->{$filePath};
						my @tempConditions = @{$tempConditionsRef};
						foreach my $line (@gffFile) {
							my ($chr,
							$source,
							$tag,
							$start,
							$end,
							$score,
							$strand,
							$phase,
							$attribute ) = split("\t", $line) or next ;
							#my $identifier = 'PAS'.'0' x (8 - length($identifier_number)).$identifier_number;
							my $tempRow = GffRows -> new (
								'seqid' => $chr,
								'source' => $source,
								'type' => $tag,
								'start' => $start,
								'end' => $end,
								'score' => $score,
								'strand' => $strand,
								'phase' => $phase,
								'attribute' => $attribute,
								'conditions' => \@tempConditions
							);
							if ($chr =~ /^\d/) {
								my $id_1; my $id_2; my $id_3;
								$id_1 = sprintf("%02u", $chr);
								$id_2 = sprintf("%05x", $start);
								$id_3 = sprintf("%05x", $start);
								if ($id_2 eq $id_3) {
									my $identifier = 'PAS'.$id_1.'X'.$id_2;
									if (exists $tempGffHash{$identifier} ) {
										my $currentConditionsRef = $tempGffHash{$identifier} -> conditions;
										my @currentConditions = @{$currentConditionsRef};
										# I should check that conditions doesn't get repeated
										push(@currentConditions, @tempConditions);
										$tempGffHash{$identifier} -> conditions (\@currentConditions);
									} else {
										$tempGffHash{$identifier} = $tempRow;
									}
								}
							} else {
								next;
							}
						}

					} else {
						print "ERROR 2 : Couldn't open \"$filePath\"\n";
						return '0';
					}
					my $gffTable = GffTable -> new (
					'gffRows' => \%tempGffHash,
					);
					$self -> gffContent($gffTable);
				}
			} else {
				print "ERROR 1 : Missing attribute 'gffFileName'\n";
				return '0';
			}
		}
	}
	sub loadWebTemplate {
	#
	#
	#
	#
		if (@_) {
			my ($self) = @_ ;
			if (my $filePath = $self -> webTemplateName) {
				if (open(WEBTEMPLATE, $filePath)) {
					#print "File succesfully opened!\n";
					my @webTemplate = <WEBTEMPLATE>;
					close WEBTEMPLATE;
					$self -> webTemplate (join("\n", @webTemplate))
						and return '1';
				} else {
					print "ERROR 2 : Couldn't open \"$filePath\"\n";
					return '0';
				}
			} else {
				print "ERROR 1 : File \"$filePath\" not found\n";
				return '0';
			}
		}
	}
	sub makeGffWebContent {
	#
	#	makeGffWebContent : creates dynamically html documents
	#
	#
		if (@_) {
			my ($self, $query) = @_ ;

			if ($self->gffContent->gffRows->{$query}) {
				#print "Creating HTML document : \"$query.html\"\n";
				my $html_doc = $self ->	webTemplate;
				$html_doc =~ s/XXX/$query/eg;
				my $start = $self->gffContent->gffRows->{$query}->start;
				my $end = $self->gffContent->gffRows->{$query}->end;
				my $tag = $self->gffContent->gffRows->{$query}->type;
				$html_doc =~ s/START_COORDINATES/$start/eg;
				$html_doc =~ s/END_COORDINATES/$end/eg;
				$html_doc =~ s/TAG/$tag/eg;
				return $html_doc;
			} else {
				print "ERROR 3 : Entry \"$query\" not found \n";
				return 0;
			}
		}
	}
	sub answerGffQuery {
	#
	#
	#
	#
		if (@_) {
			my ($self, $ENV) = @_;

			if ($ENV) {
				my $request = $ENV;
				my ($blank, $type, $id) = split "/", $request;

				#print "Content-Type:text/html\n\n";
				if ($type eq 'pas') {
					my $dynamicHtml = $self -> queryRDF($id);
					print $dynamicHtml, "\n";
					return 1;
				}
			} else {
				print "ERROR 4 : No path environment\n";
				return 0;
			}
		}
	}
	sub queryRDF {
	#
	#	This method provides the SPARQL queries that are needed for bringing
	#	information dinamically to an html document that will be loaded
	#	when the client has access to a pas url
	#
		if (@_) {
			my ($self, $query)=@_;
			#
			#	The first step is to check that the identifier that is
			#	looked for does really exists
			#
			my $queryIDString = '
				PREFIX	rdf: 	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
				PREFIX	obo:	<http://purl.obolibrary.org/obo/>
				PREFIX	pas:	<http://localhost/perl/pase.pl/browser/pas/>
				PREFIX	faldo:	<http://biohackathon.org/resource/faldo#>
				SELECT	?gene ?start ?end ?chr WHERE {
					pas:XXX rdf:type obo:SO_0000553	.
					?gene obo:SO_has_part pas:XXX	.
					?gene rdf:type obo:OGG_0000000002 .
					pas:XXX faldo:Region ?coords	.
					?coords faldo:begin ?start		.
					?coords faldo:end	?end		.
					?coords faldo:reference ?chr
				}
			';
				$queryIDString =~ s/XXX/$query/ge;
			my $queryID = RDF::Query::Client->new($queryIDString) ;
			my $iterator = $queryID -> execute('http://192.168.254.128:9999/blazegraph/namespace/pas/sparql');
			if (my $term = $iterator->next){
				#
				#	If there is any "next" in the iterator, then, the query
				#	returned some result
				#
				my $geneID	= $term -> {gene}	-> as_string	;
				my $start	= $term -> {start}	-> as_string	;
				my $end		= $term -> {end}	-> as_string	;
				my $chr		= $term -> {chr}	-> as_string	;
				$start =~ s/\"//g; $end =~ s/\"//g;
				$start	=~ s/^\d{1,2}\://g;
				$end	=~ s/^\d{1,2}\://g;
				my $html_doc= $self->webTemplate;
				$geneID =~	/\<http\:\/\/fungi\.ensembl\.org\/id\/(.*)\>/;
				my $displayGeneID = $1;
				#
				#	In the following lines, data from ensembl fungi is brought
				#	through the dbfetch script, and is analyzed using BioPerl
				#	objects in order to check where did the polyA reaction
				#	had place (exons, introns, 5UTR, 3UTR)
				my $url = 'http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&style=raw&id='.$displayGeneID;
				my $ensmblDBFetchURL = get($url);
				my $seqEnsmblIO = Bio::SeqIO -> new(
					'-string' => $ensmblDBFetchURL,
					'-format' => 'embl'
				);
				my $locationInsideGen;
				if (my $seq = $seqEnsmblIO -> next_seq) {
					my $genCords = $seq -> accession_number;
					$genCords =~ /chromosome\:.{3}:\d:(\d{1,8}):(\d{1,8}):\d/ or
						print "ERROR : error during parsing\n";
					my $genStart = $1; my $genEnd = $2;
					#	I have to ckeck the influence of the strand
					#	in the location and the coordinates
					foreach my $ft ($seq -> get_all_SeqFeatures) {
						if ($ft -> primary_tag eq 'exon') {
							my $exonStart	=	$ft -> start	;
							$exonStart = $exonStart + $genStart	;
							my $exonEnd		=	$ft -> end		;
							$exonEnd = $exonEnd + $genEnd		;

							if (($start > $exonStart) and ($end < $exonEnd)) {
								$locationInsideGen = 'EXON';
							}
						}
					}
					if (not $locationInsideGen) {
						$locationInsideGen = 'OTHER';
					}
				}
				#	The html template is replaced by the terms that have been
				#	obtained through semantic web queries. Replacing and
				#	perl regex are used to archieve this goal
				$geneID =~ s/\<//g; $geneID =~ s/\>//g;

				$html_doc =~ s/XXX/$query/ge;
				$html_doc =~ s/XSTART/$start/eg;
				$html_doc =~ s/XEND/$end/eg;
				$html_doc =~ s/XCHROMOSOME/$chr/eg;
				$html_doc =~ s/XGENEURL/$geneID/eg;
				$html_doc =~ s/XGENE/$displayGeneID/eg;
				$html_doc =~ s/XLOC/$locationInsideGen/eg;
				#
				#	This query will allow us to show the data of polyAsites
				#	with the experimental conditions in which they have been
				#	discovered
				#
				my $conditionsQueryString = '
					PREFIX	rdf: 	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX	obo:	<http://purl.obolibrary.org/obo/>
					PREFIX	pas:	<http://localhost/perl/pase.pl/browser/pas/>
					PREFIX	faldo:	<http://biohackathon.org/resource/faldo#>
					PREFIX	ensembl: <http://fungi.ensembl.org/id/>
					SELECT ?conds WHERE {
						pas:XXX rdf:type obo:SO_0000553 .
						pas:XXX obo:XCO_0000000 ?conds
					}
				';
				$conditionsQueryString =~ s/XXX/$query/eg;
				my $conditionsQuery = RDF::Query::Client -> new($conditionsQueryString);
				my $conditionsIterator = $conditionsQuery -> execute('http://192.168.254.128:9999/blazegraph/namespace/pas/sparql');
				my $conditonsListString = '<table>';	# The output of this code block
														# is a table.
				while (my $condition = $conditionsIterator -> next) {

					my $conditionURL = $condition -> {conds} -> as_string;

					$conditionURL =~ /\<http:\/\/localhost\/perl\/pase\.pl\/browser\/exc\/(.*)>/g;
					my ($conditionName) = $1;
					$conditionURL =~ s/\<//g; $conditionURL =~ s/\>//g;
					$conditonsListString = $conditonsListString.'<tr><td>'."<a href=\"$conditionURL\">$conditionName</a>".'</td></tr>';
				}
				$conditonsListString = $conditonsListString . '</table>';
				$html_doc =~ s/XTABLE1/$conditonsListString/eg;
				#
				#	The last query that is performed allows us to display
				#	the other polyAsites that we can find within the same gene
				#	and the different conditions under they appear
				#
				my $geneQueryString = '
					PREFIX	rdf: 	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
					PREFIX	obo:	<http://purl.obolibrary.org/obo/>
					PREFIX	pas:	<http://localhost/perl/pase.pl/browser/pas/>
					PREFIX	faldo:	<http://biohackathon.org/resource/faldo#>
					PREFIX	ensembl: <http://fungi.ensembl.org/id/>

					SELECT ?polyA ?conds WHERE {
						?polyA rdf:type obo:SO_0000553 .
						ensembl:ZZZ obo:SO_has_part ?polyA .
						?polyA obo:XCO_0000000 ?conds
					}
				';
				$geneQueryString =~ s/ZZZ/$displayGeneID/eg;
				my $geneQuery = RDF::Query::Client->new($geneQueryString);
				my $polyAIterator = $geneQuery -> execute('http://192.168.254.128:9999/blazegraph/namespace/pas/sparql');
				my $polyAListString = '<table>';
				while (my $polyA = $polyAIterator -> next) {
					my $polyAURL =  $polyA -> {polyA} -> as_string;
					$polyAURL =~ /\<http:\/\/localhost\/perl\/pase\.pl\/browser\/pas\/(.*)>/g;
					my ($polyAName) = $1;
					if ($polyAName ne $query) {
						#
						#	This conditional block has as purpose to avoid
						#	displaying information about the self-polyA site
						#
						$polyAURL =~ s/\<//g; $polyAURL =~ s/\>//g;
						my $polyAConds =  $polyA -> {conds} -> as_string;
						$polyAConds =~ /\<http:\/\/localhost\/perl\/pase\.pl\/browser\/exc\/(.*)>/g;
						my ($polyACondsName) = $1;
						$polyAConds=~ s/\<//g; $polyAConds=~ s/\>//g;
						$polyAListString = $polyAListString . '<tr><td>'."<a href=\"$polyAURL\">$polyAName</a>".'</td>'.'<td>'."<a href=\"$polyAConds\">$polyACondsName</a></td></tr>";
					} else {
						next;
					}
				}
				$polyAListString = $polyAListString.'</table>';
				$html_doc =~ s/XTABLE2/$polyAListString/eg;
				return $html_doc;
			} else {
				print "Not found\n";
			}

		}
	}
#Do not write bellow this line
1;
