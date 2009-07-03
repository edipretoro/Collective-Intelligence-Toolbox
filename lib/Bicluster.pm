package Bicluster;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {};

    $self->{left} = defined $args{left} ? $args{left} : 'None';
    $self->{right} = defined $args{left} ? $args{right} : 'None';
    $self->{vec} = defined $args{vec} ? $args{vec} : [];
    $self->{distance} = defined $args{distance} ? $args{distance} : 0.0;
    $self->{id} = defined $args{id} ? $args{id} : 'None';

    bless $self, $class;
}

sub vec {
    my $self = shift;
    return $self->{vec};
}

sub id {
    my $self = shift;
    return $self->{id};
}

sub left {
    my $self = shift;
    return $self->{left};
}

sub right {
    my $self = shift;
    return $self->{right};
}

sub distance {
    my $self = shift;
    return $self->{distance};
}

1;
