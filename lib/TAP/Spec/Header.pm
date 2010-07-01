package TAP::Spec::Header;
# ABSTRACT: Information at the beginning of a TAP stream
use Moose;
use namespace::autoclean;

use TAP::Spec::Comment ();
use TAP::Spec::Version ();

has 'comments' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_comments',
);

has 'version' => (
  is => 'rw',
  isa => 'TAP::Spec::Version',
  predicate => 'has_version',
);

sub as_tap {
  my ($self) = @_;

  my $tap = "";

  if ($self->has_comments) {
    $tap .= $_->as_tap for @{ $self->comments };
  }
  $tap .= $self->version->as_tap if $self->has_version;

  return $tap;
}

__PACKAGE__->meta->make_immutable;
1;
