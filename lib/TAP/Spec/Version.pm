package TAP::Spec::Version;
# ABSTRACT: A TAP version number specification
# VERSION
# AUTHORITY
use Mouse;
use namespace::autoclean;

=attr version_number

B<Required>: The TAP version number (integer).

=cut

has 'version_number' => (
  is => 'rw',
  isa => 'Int',
  required => 1,
);

=method $version->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  return "TAP version " . $self->version_number . "\n";
}

__PACKAGE__->meta->make_immutable;
