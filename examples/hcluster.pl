#!/usr/bin/env perl

use Modern::Perl;
use lib './lib';
use Collective::Intelligence::Toolbox qw( :all );
use Devel::Size qw( total_size );
use Number::Bytes::Human qw( format_bytes );

$SIG{__WARN__} = sub { CORE::die "Warning:\n", @_, "\n" };

my $filename = shift;

my ($rownames, $colnames, $data) = readfile( $filename );
my $clust = hcluster($data);

say format_bytes( total_size( $clust ));
my $left = $clust->left();
my $right = $clust->right();

my $test = 'None';

say ref($left);
say ref($right);
say ref($test);
say ($left);
say ($right);
say ($test);
say $clust->id();

