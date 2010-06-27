package TAP::Spec::BailOut;
use Moose;
use namespace::autoclean;

has 'reason' => (
  is => 'rw',
  isa => 'Str',
  predicate => 'has_reason',
);

sub as_tap {
  my ($self) = @_;

  my $tap = "Bail out!";
  $tap .= " " . $self->reason if $self->has_reason;
  $tap .= "\n";

  return $tap;
}

__PACKAGE__->meta->make_immutable;
1;
