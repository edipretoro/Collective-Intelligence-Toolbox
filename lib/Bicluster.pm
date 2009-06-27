package Bicluster;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {};

    $self->{left} = $args{left} || 'None';
    $self->{right} = $args{right} || 'None';
    $self->{vec} = $args{vec};
    $self->{distance} = $args{distance} || 0.0;
    $self->{id} = $args{id} || 'None';

    bless $self, $class;
}

1;
