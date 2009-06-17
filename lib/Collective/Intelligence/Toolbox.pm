package Collective::Intelligence::Toolbox;

use warnings;
use strict;

use parent qw( Exporter );

our @EXPORT = ();
our @EXPORT_OK = qw(
  &sim_distance
  &sim_pearson
  &topMatches
);
our %EXPORT_TAGS = (
    all => [
        qw( &sim_distance &sim_pearson &topMatches )
    ],
    chapter01 => [
        qw( &sim_distance &sim_pearson &topMatches )
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
    return @scores[0..$n - 1];
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
