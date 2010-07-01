package TAP::Spec::Body;
# ABSTRACT: The main body of a TAP testset
use Moose;
use namespace::autoclean;

use TAP::Spec::Comment ();
use TAP::Spec::TestResult ();
use TAP::Spec::BailOut ();

=attr lines

B<Optional>: The lines (TestResults, Comments, BailOuts) of the body.
TODO: remove the predicate and make it default => [] once Regexp::Grammars
calls constructors.

=cut

has 'lines' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_lines',
);

=method $body->tests

Returns a list of the test results from the C<lines>.

=cut

sub tests {
  my ($self) = @_;

  return () unless $self->has_lines;
  return grep $_->isa('TAP::Spec::TestResult'), @{ $self->lines };
}

=method $body->as_tap

TAP representation.

=cut

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
