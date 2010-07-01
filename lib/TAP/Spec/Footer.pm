package TAP::Spec::Footer;
# ABSTRACT: Trailing information in a TAP stream
use Moose;
use namespace::autoclean;

use TAP::Spec::Comment ();

=attr comments

B<Optional>: An arrayref of footer comments

=cut

has 'comments' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_comments',
);

=method $footer->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  my $tap = "";

  if ($self->has_comments) {
    $tap .= $_->as_tap for @{ $self->comments };
  }

  return $tap;
}

__PACKAGE__->meta->make_immutable;
