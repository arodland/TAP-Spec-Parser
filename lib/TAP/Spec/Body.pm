package TAP::Spec::Body;
use Moose;
use namespace::autoclean;

use TAP::Spec::Comment ();
use TAP::Spec::TestResult ();
use TAP::Spec::BailOut ();

has 'lines' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_lines',
);

sub as_tap {
  my ($self) = @_;

  my $tap = "";
  return "" unless $self->has_lines;

  for my $line (@{ $self->lines }) {
    $tap .= $line->as_tap;
  }

  return $tap;
}

__PACKAGE__->meta->make_immutable;
1;
