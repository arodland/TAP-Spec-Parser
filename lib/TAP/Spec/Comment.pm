package TAP::Spec::Comment;
# ABSTRACT: A comment in a TAP stream
use Moose;
use namespace::autoclean;

has 'text' => (
  is => 'rw',
  isa => 'Str',
  required => 1,
);

sub as_tap {
  my ($self) = @_;

  return "#" . $self->text . "\n";
}

__PACKAGE__->meta->make_immutable;
1;
