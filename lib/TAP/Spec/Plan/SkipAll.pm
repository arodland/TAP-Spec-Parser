package TAP::Spec::Plan::SkipAll;
# ABSTRACT: A TAP plan indicating that all tests were skipped
# VERSION
# AUTHORITY
use Mouse;
use namespace::autoclean;
extends 'TAP::Spec::Plan';

=attr reason

B<Required>: The reason for skipping all tests.

=cut

has 'reason' => ( 
  is => 'rw',
  isa => 'Str',
  required => 1,
);

=method $plan->number_of_tests

Returns 0 (all tests were skipped)

=cut

sub number_of_tests { 0 }

=method $plan->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  return "1..0 skip " . $self->reason . "\n";
}

__PACKAGE__->meta->make_immutable;
