package TAP::Spec::BailOut;
# ABSTRACT: A TAP Bail Out! line
use Mouse;
use namespace::autoclean;

=attr reason

B<Optional>: The reason why testing was ended.

=cut

has 'reason' => (
  is => 'rw',
  isa => 'Str',
  predicate => 'has_reason',
);

=method $bail_out->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  my $tap = "Bail out!";
  $tap .= " " . $self->reason if $self->has_reason;
  $tap .= "\n";

  return $tap;
}

__PACKAGE__->meta->make_immutable;
