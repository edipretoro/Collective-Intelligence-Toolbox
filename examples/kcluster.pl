#!/usr/bin/env perl

use Modern::Perl;
use lib './lib';
use Collective::Intelligence::Toolbox qw( :all );
use Devel::Size qw( total_size );
use Number::Bytes::Human qw( format_bytes );

$SIG{__WARN__} = sub { CORE::die "Warning:\n", @_, "\n" };

my $filename = shift;

my ($rownames, $colnames, $data) = readfile( $filename );
say "Just start to work...";

my $kclust = kcluster($data, \&pearson, 10);

