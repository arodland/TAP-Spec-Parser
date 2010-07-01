package TAP::Spec::Plan::SkipAll;
# ABSTRACT: A TAP plan indicating that all tests were skipped
use Moose;
use namespace::autoclean;
extends 'TAP::Spec::Plan';

has 'reason' => ( 
  is => 'rw',
  isa => 'Str',
  required => 1,
);

sub number_of_tests { 0 }

sub as_tap {
  my ($self) = @_;

  return "1..0 skip " . $self->reason . "\n";
}

__PACKAGE__->meta->make_immutable;
