package TAP::Spec::Plan::Todo;
# ABSTRACT: A legacy TAP plan indicating TODO tests
use Mouse;
use namespace::autoclean;
extends 'TAP::Spec::Plan::Simple';

=attr skipped_tests

B<Required>: An arrayref of the test numbers that should be considered
TODO.

=cut

has 'skipped_tests' => (
  is => 'rw',
  isa => 'ArrayRef',
  required => 1,
);

=method $plan->as_tap

TAP Representation.

=cut

around 'as_tap' => sub {
  my ($self, $inner) = @_;

  my $tap = $inner->();
  my $append = " todo";
  $append .= " $_" for @{ $self->skipped_tests };
  $tap =~ s/$/$append/;
  return $tap;
};

__PACKAGE__->meta->make_immutable;
