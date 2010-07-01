package TAP::Spec::Version;
# ABSTRACT: A TAP version number specification
use Moose;
use namespace::autoclean;

has 'version_number' => (
  is => 'rw',
  isa => 'Int',
  required => 1,
);

sub as_tap {
  my ($self) = @_;

  return "TAP version " . $self->version_number . "\n";
}

__PACKAGE__->meta->make_immutable;
1;
