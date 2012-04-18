package TAP::Spec::Plan::Simple;
# ABSTRACT: A basic TAP plan with a number of tests
# VERSION
# AUTHORITY
use Mouse;
use namespace::autoclean;
extends 'TAP::Spec::Plan';

=attr number_of_tests

B<Required>: The number of tests planned

=cut

has 'number_of_tests' => (
  is => 'rw',
  isa => 'Num',
  required => 1,
);

=method $plan->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;
  return "1.." . $self->number_of_tests . "\n";
}

__PACKAGE__->meta->make_immutable;
