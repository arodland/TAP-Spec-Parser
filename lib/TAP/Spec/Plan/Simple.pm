package TAP::Spec::Plan::Simple;
# ABSTRACT: A basic TAP plan with a number of tests
use Moose;
use namespace::autoclean;
extends 'TAP::Spec::Plan';

has 'number_of_tests' => (
  is => 'rw',
  isa => 'Num',
  required => 1,
);

sub as_tap {
  my ($self) = @_;
  return "1.." . $self->number_of_tests . "\n";
}

__PACKAGE__->meta->make_immutable;
