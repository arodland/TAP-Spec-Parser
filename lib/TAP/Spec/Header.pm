package TAP::Spec::Header;
# ABSTRACT: Information at the beginning of a TAP stream
# VERSION
# AUTHORITY
use Mouse;
use namespace::autoclean;

use TAP::Spec::Comment ();
use TAP::Spec::Version ();

=attr comments

B<Optional>: An arrayref of header comments

=cut

has 'comments' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_comments',
);

=attr version

B<Optional>: The TAP version

=cut

has 'version' => (
  is => 'rw',
  isa => 'TAP::Spec::Version',
  predicate => 'has_version',
);

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

=method $header->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  my $tap = "";

  if ($self->has_leading_junk) {
    $tap .= $_->as_tap for @{ $self->leading_junk };
  }

  if ($self->has_comments) {
    $tap .= $_->as_tap for @{ $self->comments };
  }
  $tap .= $self->version->as_tap if $self->has_version;

  if ($self->has_trailing_junk) {
    $tap .= $_->as_tap for @{ $self->trailing_junk };
  }

  return $tap;
}

__PACKAGE__->meta->make_immutable;
