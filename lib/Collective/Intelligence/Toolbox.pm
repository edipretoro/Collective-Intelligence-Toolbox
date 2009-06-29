package Collective::Intelligence::Toolbox;

use warnings;
use strict;
use Carp;

use parent qw( Exporter );

use Net::Delicious::RSS qw( get_popular get_urlposts get_userposts );
use File::Slurp;
use File::Spec;
use List::Util qw( sum );

our @EXPORT = ();
our @EXPORT_OK = qw(
  &sim_distance
  &sim_pearson
  &topMatches
  &getRecommendations
  &transformPrefs
  &initializeUserDict
  &fillItems
  &calculateSimilarItems
  &getRecommendedItems
  &loadMovieLens

  &readfile
  &pearson
);
our %EXPORT_TAGS = (
    all => [
        qw( 
              &sim_distance 
              &sim_pearson 
              &topMatches 
              &getRecommendations 
              &transformPrefs 
              &initializeUserDict 
              &fillItems 
              &calculateSimilarItems 
              &getRecommendedItems 
              &loadMovieLens 

              &readfile
              &pearson
)
    ],
    chapter01 => [
        qw( &sim_distance &sim_pearson &topMatches &getRecommendations &transformPrefs &initializeUserDict &fillItems &calculateSimilarItems &getRecommendedItems &loadMovieLens )
    ],
    chapter02 => [
        qw( &readfile &pearson )
    ],
);

=head1 NAME

Collective::Intelligence::Toolbox - Algorithms presented in Programming Collective Intelligence by Toby Segaran

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Collective::Intelligence::Toolbox;

    my $foo = Collective::Intelligence::Toolbox->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 sim_distance

=cut

sub sim_distance {
    my ( $prefs, $person1, $person2 ) = @_;

    my %si;
    my $sum_of_squares;
    
    foreach my $item (keys %{$prefs->{$person1}}) {
        $si{$item} = 1 if exists $prefs->{$person2}{$item};
    }

    return 0 if scalar(keys(%si)) == 0;

    foreach my $item (keys %{$prefs->{$person1}}) {
        $sum_of_squares += ($prefs->{$person1}{$item} - $prefs->{$person2}{$item}) ** 2 if exists $prefs->{$person2}{$item};
    }

    return 1/(1 + $sum_of_squares);
}

=head2 sim_pearson

=cut

sub sim_pearson {
    my ( $prefs, $person1, $person2 ) = @_;

    my %si;
    my $result;
    my $sum1, my $sum1Sq;
    my $sum2, my $sum2Sq;
    my $pSum;
    my $num, my $den;
    
    foreach my $item (keys %{$prefs->{$person1}}) {
        $si{$item} = 1 if exists $prefs->{$person2}{$item};
    }

    my $n = scalar(keys(%si));

    return 0 if $n == 0;

    foreach my $item (keys %si) {
        $sum1 += $prefs->{$person1}{$item};
        $sum2 += $prefs->{$person2}{$item};
        $sum1Sq += $prefs->{$person1}{$item} ** 2;
        $sum2Sq += $prefs->{$person2}{$item} ** 2;
        $pSum +=  $prefs->{$person1}{$item} * $prefs->{$person2}{$item};
    }

    $num = $pSum  - ($sum1 * $sum2 / $n);
    $den = sqrt(($sum1Sq - ($sum1 ** 2) / $n) * ($sum2Sq - ($sum2 ** 2) / $n));
    return 0 if $den == 0;

    return $num / $den;
}

=head2 topMatches

=cut

sub topMatches {
    my ($prefs, $person, $n, $similarity) = @_;
    $n = 5 if not defined $n;
    $similarity = \&sim_pearson if not defined $similarity;
    my @scores;
    
    foreach my $other (keys %$prefs) {
        if ($other ne $person) {
            push @scores, [ $similarity->($prefs, $person, $other), $other ];
        }
    }
    
    @scores = sort { $b->[0] <=> $a->[0] } @scores;
    return [ @scores[0..$n - 1] ];
}

=head2 getRecommendations

=cut

sub getRecommendations {
    my ($prefs, $person, $similarity) = @_;
    $similarity = \&sim_pearson if not defined $similarity;

    my %totals, my %simSums;
    my @rankings;

    foreach my $other (keys %$prefs) {
        next if $other eq $person;

        my $sim  = $similarity->($prefs, $person, $other);
        next if $sim <= 0;
        foreach my $item (keys %{$prefs->{$other}}) {
            if (not defined $prefs->{$person}{$item} or $prefs->{$person}{$item} == 0) {
                $totals{$item} += $prefs->{$other}{$item} * $sim;
                $simSums{$item} += $sim;
            }
        }
    }

    foreach my $item (keys %totals) {
        push @rankings, [ $totals{$item} / $simSums{$item}, $item ];
    }

    @rankings = sort { $b->[0] <=> $a->[0] } @rankings;

    return [ @rankings ];
}

=head2 transformPrefs

=cut

sub transformPrefs {
    my $prefs = shift;
    my %results;
    
    foreach my $person (keys %$prefs) {
        foreach my $item (keys %{$prefs->{$person}}) {
            $results{$item}{$person} = $prefs->{$person}{$item};
        }
    }

    return \%results;
}

=head2 initializeUserDict

=cut

sub initializeUserDict {
    my ( $tag, $count ) = @_;
    $count = 5 unless $count;

    my $user_dict = {};

    foreach my $p1 (@{get_popular($tag)}[0..$count]) {
        foreach my $p2 (@{get_urlposts($p1->{href})}) {
            my $user = $p2->{user};
            $user_dict->{$user} = {};
        }
    }

    return $user_dict;
}

=head2

=cut

sub fillItems {
    my $user_dict = shift;
    my $all_items = {};
    
    foreach my $user (keys %$user_dict) {
        my $posts = get_userposts($user);
        foreach my $post (@$posts) {
            my $url = $post->{href};
            $user_dict->{$user}{$url} = 1.0;
            $all_items->{$url} = 1;
        }
    }

    foreach my $url (keys %$all_items) {
        foreach my $user (keys %$user_dict) {
            $user_dict->{$user}{$url} = 0 if not exists $user_dict->{$user}{$url};
        }
    }
}

=head2

=cut

sub calculateSimilarItems {
    my ( $prefs, $n ) = @_;
    $n = 10 unless $n;

    my $results = {};
    my $itemPrefs = transformPrefs( $prefs );
    my $c = 0;

    foreach my $item (keys %$itemPrefs) {
        $c++;
        printf ("%d / %d", $c, scalar(keys %$itemPrefs)) if ($c % 100) == 0;
        my $scores = topMatches( $itemPrefs, $item, $n, \&sim_distance);
        $results->{$item} = $scores;        
    }

    return $results;
}

=head2

=cut

sub getRecommendedItems {
    my ( $prefs, $itemMatch, $user ) = @_;
    my $scores = {};
    my $totalSim = {};
    my $userRating = $prefs->{$user};

    while (my ($item, $rating) = each %$userRating) {
        foreach my $item2 (@{$itemMatch->{$item}}) {
            next if exists $userRating->{$item2->[1]};
            $scores->{$item2->[1]} += $item2->[0] * $rating;
            $totalSim->{$item2->[1]} += $item2->[0];
        }
    }

    my @rankings;
    while (my ($item, $score) = each %$scores) {
        push @rankings, [ $score / $totalSim->{$item}, $item]
    }
    
    @rankings = sort { $b->[0] <=> $a->[0] } @rankings;
    return [ @rankings ];
}

=head2

=cut

sub loadMovieLens {
    my $path = shift;
    $path = './movielen';

    my $movies = {};
    foreach my $line (read_file( File::Spec->catfile( $path, '/u.item' ))) {
        my @fields = split('\|', $line);
        $movies->{$fields[0]} = $fields[1];
    }

    my $prefs = {};
    foreach my $line (read_file( File::Spec->catfile( $path, '/u.data' ))) {
        my ($user, $movieid, $rating, $ts) = split('\t', $line);
        $prefs->{$user}{$movies->{$movieid}} = sprintf('%f', $rating);
    }

    return $prefs;
}

=head2 readfile

=cut

sub readfile {
    my $filename = shift;
    my @lines = read_file( $filename );

    my @colnames = split('\t', shift(@lines));
    my @rownames;
    my @data;

    foreach my $line (@lines) {
        my @p = split('\t', $line);
        push @rownames, shift(@p);
        my @val;
        map { push @val, sprintf('%f', $_) } @p[1..$#p];
        push @data, [ @val ];
    }
    
    return [ @rownames ], [ @colnames ], [ @data ];
}

sub pearson {
    my ($v1, $v2) = @_;

    my $sum1 = sum(@{$v1});
    my $sum2 = sum(@{$v2});

    my $sum1Sq = sum( map { $_ ** 2 } @{$v1} );
    my $sum2Sq = sum( map { $_ ** 2 } @{$v2} );

    my $pSum = sum( map { $v1->[$_] * $v2->[$_] } 0 .. scalar(@{$v1}) - 1 );

    my $num = $pSum - ( $sum1 * $sum2 / scalar(@{$v1}) );
    my $den = sqrt((($sum1Sq - $sum1 ** 2) / scalar(@{$v1})) * (($sum2Sq - $sum2 ** 2) / scalar(@{$v1})) );

    return 0 if $den == 0;

    return 1.0 - ($num / $den);
}

=head1 AUTHOR

Emmanuel Di Pretoro, C<< <edipretoro at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-collective-intelligence-toolbox at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Collective-Intelligence-Toolbox>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Collective::Intelligence::Toolbox


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Collective-Intelligence-Toolbox>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Collective-Intelligence-Toolbox>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Collective-Intelligence-Toolbox>

=item * Search CPAN

L<http://search.cpan.org/dist/Collective-Intelligence-Toolbox/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Emmanuel Di Pretoro, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Collective::Intelligence::Toolbox
