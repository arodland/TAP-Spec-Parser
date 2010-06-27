package TAP::Spec::Footer;

use Moose;
use namespace::autoclean;

use TAP::Spec::Comment ();

has 'comments' => (
  is => 'rw',
  isa => 'ArrayRef',
  predicate => 'has_comments',
);

sub as_tap {
  my ($self) = @_;

  my $tap = "";

  if ($self->has_comments) {
    $tap .= $_->as_tap for @{ $self->comments };
  }

  return $tap;
}

__PACKAGE__->meta->make_immutable;
1;
