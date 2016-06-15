#!/usrl/bin/perl
# 7th June 2016
#By Bruno Cuevas
#Final Project - Challenges Programming in Bioinformatics, 2015-2016.
#
# Descripción
#	This class has as pupose to create RDF that links our localhost/PAS/
#	idenfitiers with ensmbl fungi idenfitiers in order to provide
#	RDF triples
#
# ____________________________________________________________________________ #
package pas2RDF ;
	use Moose;
	use strict;
	use warnings;
	use RDF::Trine::Store::Memory	;
	use RDF::Trine::Model			;
	use RDF::Trine::Node::Resource	;
	use RDF::Trine::Node::Literal	;
	use RDF::Trine::Statement		;
	use RDF::Trine::Serializer::NTriples;
	use RDF::Trine::Node::Literal;
	use GffRows;
	use GffDWM;
	has 'rdfFileOut' => (
		'is' => 'rw',
		'isa' => 'Str'
	);
	sub linkData {
		if (@_) {
			my ($self, $gffDWMInstance) = @_ ;
			foreach my $gffRowID (sort keys %{$gffDWMInstance -> gffContent -> gffRows}) {
				my $exit1 = $self -> linkDataToEnsmbl($gffRowID, $gffDWMInstance -> gffContent -> gffRows -> {$gffRowID});
				my $exit2 = $self -> linkDataToCoordinates($gffRowID, $gffDWMInstance -> gffContent -> gffRows -> {$gffRowID});
				my $exit3 = $self -> linkDataToConditions($gffRowID, $gffDWMInstance -> gffContent -> gffRows -> {$gffRowID});
				my $exit4 = $self -> linkDataToType($gffRowID, $gffDWMInstance -> gffContent -> gffRows -> {$gffRowID});
				if ($exit1 + $exit2 + $exit3 + $exit4 ne 4) {
					print "ERROR 1 : Something went wrong\n";
					return '0';
				}
			}
			return '1';

		}
	}
	sub linkDataToEnsmbl {
	#
	#
	#
	#
		if (@_) {
			my ($self, $id, $gffRow) = @_;
			my $store = RDF::Trine::Store::Memory->new();
			my $model = RDF::Trine::Model->new($store);
			my $serializer = RDF::Trine::Serializer::NTriples -> new ();
			my $p = RDF::Trine::Node::Resource -> new ('http://purl.obolibrary.org/obo/SO_has_part');
			my $o = RDF::Trine::Node::Resource -> new ('http://localhost/perl/pase.pl/browser/pas/'.$id);
			my $gene_name = $gffRow -> attribute;
				$gene_name =~ s/gene=//ig;
				$gene_name =~ s/\;//ig;
			#print $gene_name, "\n";
			my $s = RDF::Trine::Node::Resource -> new ('http://fungi.ensembl.org/id/'.$gene_name);
			my $spo = RDF::Trine::Statement -> new ($s, $p, $o);
			$model -> add_statement($spo);
			$p = RDF::Trine::Node::Resource -> new ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type');
			$o = RDF::Trine::Node::Resource -> new ('http://purl.obolibrary.org/obo/OGG_0000000002');
			$spo = RDF::Trine::Statement -> new($s, $p, $o);
			$model -> add_statement($spo);
			my $FILEOUT;
			if (open($FILEOUT, '>>'.$self->rdfFileOut)) {
				$serializer -> serialize_model_to_file($FILEOUT, $model);
				close ($FILEOUT);
				return '1';
			} else {
				return '0';
			}
		}
	}
	sub linkDataToCoordinates {
		if (@_) {
			my ($self, $id, $gffRow) = @_ ;
			my $store = RDF::Trine::Store::Memory->new();
			my $model = RDF::Trine::Model->new($store);
			my $serializer = RDF::Trine::Serializer::NTriples->new();
			my $s = RDF::Trine::Node::Resource -> new ('http://localhost/perl/pase.pl/browser/pas/'.$id);
			my $p = RDF::Trine::Node::Resource -> new ('http://biohackathon.org/resource/faldo#Region');
			my $coordinates ;
				$coordinates = $gffRow -> seqid;
				$coordinates = $coordinates.':'.$gffRow -> start;
				$coordinates = $coordinates.':'.$gffRow -> end;
			my $o = RDF::Trine::Node::Resource -> new ('http://localhost/perl/pase.pl/browser/mgg/'.$coordinates);
			my $spo = RDF::Trine::Statement -> new ($s, $p, $o);
			$model -> add_statement($spo);
			$s = $o;
			$p = RDF::Trine::Node::Resource -> new ('http://biohackathon.org/resource/faldo#begin');
			$o = RDF::Trine::Node::Literal -> new ($gffRow -> seqid.':'.$gffRow -> start);
			$spo = RDF::Trine::Statement -> new ($s, $p, $o);
			$model -> add_statement($spo);
			$p = RDF::Trine::Node::Resource -> new ('http://biohackathon.org/resource/faldo#end');
			$o = RDF::Trine::Node::Literal -> new ($gffRow -> seqid.':'.$gffRow -> end);
			$spo = RDF::Trine::Statement -> new ($s, $p, $o);
			$model -> add_statement($spo);
			$p = RDF::Trine::Node::Resource -> new ('http://biohackathon.org/resource/faldo#reference');
			$o = RDF::Trine::Node::Literal -> new ($gffRow -> seqid);
			$spo = RDF::Trine::Statement -> new ($s, $p, $o);
			$model -> add_statement($spo);
			if (open(my $FILEOUT, '>>'.$self -> rdfFileOut)) {
				$serializer -> serialize_model_to_file($FILEOUT, $model);
				close ($FILEOUT);
				return '1';
			} else {
				return '0';
			}
		}
	}
	sub linkDataToConditions {
	#
	#
	#
	#
		if (@_) {
			my ($self, $id, $gffRow) = @_ ;
			my $store = RDF::Trine::Store::Memory->new();
			my $model = RDF::Trine::Model->new($store);
			my $serializer = RDF::Trine::Serializer::NTriples -> new ();
			my $p = RDF::Trine::Node::Resource -> new ('http://purl.obolibrary.org/obo/XCO_0000000');
			my $s = RDF::Trine::Node::Resource -> new ('http://localhost/perl/pase.pl/browser/pas/'.$id);
			my @conditionsList = @{$gffRow -> conditions};

			foreach my $condition (@conditionsList) {
				my $o = RDF::Trine::Node::Resource -> new ('http://localhost/perl/pase.pl/browser/exc/'.$condition);
				my $spo = RDF::Trine::Statement -> new ($s, $p, $o);
				$model -> add_statement($spo);
			}
			if (open(my $FILEOUT, '>>'.$self->rdfFileOut)) {
				$serializer -> serialize_model_to_file($FILEOUT, $model);
				close ($FILEOUT);
				return '1';
			} else {
				return '0';
			}
		}
	}
	sub linkDataToType {
		if (@_) {
			my ($self, $id, $gffRow) = @_;
			my $store = RDF::Trine::Store::Memory->new();
			my $model = RDF::Trine::Model->new($store);
			my $serializer = RDF::Trine::Serializer::NTriples->new;
			my $s = RDF::Trine::Node::Resource -> new ('http://localhost/perl/pase.pl/browser/pas/'.$id);
			my $p = RDF::Trine::Node::Resource -> new ('http://www.w3.org/1999/02/22-rdf-syntax-ns#type');
			my $o = RDF::Trine::Node::Resource -> new ('http://purl.obolibrary.org/obo/SO_0000553');
			my $spo = RDF::Trine::Statement -> new ($s, $p, $o);
			$model -> add_statement($spo);
			if (open(my $FILEOUT , '>>'. $self->rdfFileOut)) {
				$serializer -> serialize_model_to_file($FILEOUT, $model);
				close($FILEOUT);
				return '1';
			} else {
				return '0';
			}

		}
	}


# Don't write bellow this line
1;
