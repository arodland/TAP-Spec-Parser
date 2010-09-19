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

=attr leading_junk

B<Optional>: leading junk lines

=cut

has 'leading_junk' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_leading_junk',
);

=attr trailing_junk

B<Optional>: trailing junk lines

=cut

has 'trailing_junk' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_trailing_junk',
);

sub as_tap {
  my ($self) = @_;

  my $tap = "";

  if ($self->has_leading_junk) {
    $tap .= $_->as_tap for @{ $self->leading_junk };
  }

  if ($self->has_comments) {
    $tap .= $_->as_tap for @{ $self->comments };
  }

  if ($self->has_trailing_junk) {
    $tap .= $_->as_tap for @{ $self->trailing_junk };
  }

  return $tap;
}

__PACKAGE__->meta->make_immutable;
