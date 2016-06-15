#!/usrl/bin/perl
#Date
#By Bruno Cuevas
#Final Project - Challenges Programming in Bioinformatics, 2015-2016.
#
# Descripción
#	This object creates the web content for
#	each of the genes that we are working with
#
#
# ____________________________________________________________________________ #
package geneDWM ;
	use Moose;
	use strict;
	use warnings;
	use LWP::Simple;
	use Bio::Seq;
	use Bio::SeqIO;
	has 'tempGeneInfo' => (
		'is' => 'rw',
		'isa' => 'Bio::SeqIO',
		'required' => 0
	);
	has 'webTemplateName' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'webTemplate' => (
		'is' => 'rw',
		'isa' => 'Str',
		'required' => 0
	);
	sub getGeneInfo {
		if (@_) {
			my ($self, $query) = @_ ;
			my $url = 'http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&id=XXX&style=raw&format=embl';
			$url =~ s/XXX/$query/e;
			print $url, "\n";
			my $emblString = get($url) or die "ERROR 1 : Couldn't get to page!\n";
			if ($emblString) {
				my $seqIOInstance = Bio::SeqIO -> new (
					'-string' => $emblString,
					'-format' => 'embl'
				);
				print "creating seqIO Instance\n";
				$self -> tempGeneInfo($seqIOInstance) and return '1';

			} else {
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
	sub makeGeneWebContent {
	#
	#
	#
	#
		if (@_) {
			my ($self, $query) = @_;
			if ($self -> getGeneInfo ($query)) {
				my $htmlDoc = $self -> webTemplate	;
				my $seq = $self -> tempGeneInfo -> next_seq	;
				my $primaryID	= $seq -> primary_id($query);


				my $organism	= $seq -> species -> ncbi_taxid	;
				my $length		= $seq -> length	;
				my $sequence	= $seq -> seq		;
				my $lineNumber	= 0					;
				my @formatedSequence	;
				while ($lineNumber < ($length/25)) {
					if ($sequence =~ s/^(.{25})//g) {
						push(@formatedSequence, $1.'<br>');
					}
					$lineNumber ++;
				}
				push(@formatedSequence, $sequence);
				$sequence = join("\n", @formatedSequence);


				$htmlDoc =~ s/XXX/$primaryID/eg	;
				$htmlDoc =~ s/YYY/$organism/eg	;
				$htmlDoc =~ s/ZZZ/$length/eg	;
				$htmlDoc =~ s/SEQ/$sequence/eg	;
				return $htmlDoc;

			} else {
				print "ERROR 3 : Gene not found\n";
			}

		}
	}
	sub answerGeneQuery {
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
				if ($type eq 'gen') {
					my $dynamicHtml = $self -> makeGeneWebContent($id);
					print $dynamicHtml, "\n";
					return 1;
				}
			} else {
				print "ERROR 4 : No path environment\n";
				return 0;
			}
		}
	}

# Don't write bellow this line
1;
