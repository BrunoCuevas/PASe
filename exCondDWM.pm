#!/usrl/bin/perl
#Date
#By Bruno Cuevas
#Final Project - Challenges Programming in Bioinformatics, 2015-2016.
#
# This object will be used to read the avalaible experimental conditions
#	in which some experimental data was obtained
#
#
#
# ____________________________________________________________________________ #
package exCondDWM;
	use Moose;
	use strict;
	use warnings;
	use Data::Dumper;
	use exCondRow;
	has 'exCondFileName' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	has 'exCondContent' => (
		'is' => 'rw',
		'isa' => 'HashRef[exCondRow]',
		'required' => 0
	);
	has 'webTemplateName' => (
		'is' => 'rw',
		'isa' => 'Str',
		'required' => 0
	);
	has 'webTemplate' => (
		'is'	=> 'rw',
		'isa' 	=> 'Str',
		'required' => 0
	);


	sub loadExCondContent {
	#
	#
	#
	#
		if (@_) {
			my ($self) = @_	;
			if (my $filePath = $self -> exCondFileName) {
				if (open(EXCOND, $filePath)) {
					my @exCondFile = <EXCOND>	;
					my %tempExCondHash			;
					chomp (@exCondFile)			;
					shift(@exCondFile)			;
					foreach my $line (@exCondFile) {
						my ($identifier, $tag, $description) = split ("\t", $line);
						my $tempExCondRow = exCondRow -> new (
							'tag' => $tag,
							'description' => $description
						);
						$tempExCondHash{$identifier} = $tempExCondRow;
					}
					$self -> exCondContent(\%tempExCondHash);
					return '1';
				} else {
					print "ERROR 2 : Couldn't open \"$filePath\"\n";
					return '0';
				}
			} else {
				print "ERROR 1 : Missing attribute 'exCondFileName'\n";
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
	sub makeExCondWebContent {
	#
	#
	#
	#
		if (@_) {
			my ($self, $query) = @_ ;
			if ($self-> exCondContent -> {$query}){
				my $html_doc = $self -> webTemplate;
				$html_doc =~ s/XXX/$query/eg;
				my $tag = $self -> exCondContent-> {$query} -> tag;
				$html_doc =~ s/XTAG/$tag/eg;
				my $description = $self -> exCondContent -> {$query} -> description;
				$html_doc =~ s/XDESCRIPTION/$description/eg;
				return $html_doc;
			} else {
				print "ERROR 3 : Entry \"$query\" not found\n";
				return 0;
			}
		}
	}
	sub answerExCondQuery {
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
				if ($type eq 'exc') {
					my $dynamicHtml = $self -> makeExCondWebContent($id);
					print $dynamicHtml, "\n";
					return 1;
				} else {
					next ;

				}
			} else {
				print "ERROR 4 : No path environment\n";
				return 0;
			}
		}
	}

# Don't write bellow this line
1;
