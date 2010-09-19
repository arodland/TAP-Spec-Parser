package TAP::Spec::TestResult;
# ABSTRACT: The results of a single test
use Mouse;
use Mouse::Util::TypeConstraints;
use namespace::autoclean;

enum 'TAP::Spec::TestStatus' => ('ok', 'not ok');
enum 'TAP::Spec::Directive' => qw(SKIP TODO);
subtype 'TAP::Spec::TestNumber' => as 'Int', where { $_ > 0 };

=attr status

B<Required>: The status of the test ("ok" or "not ok").

=cut

has 'status' => (
  is => 'rw',
  isa => 'TAP::Spec::TestStatus',
  required => 1,
);

=attr number

B<Optional>: Test number.

=cut

has 'number' => (
  is => 'rw',
  isa => 'TAP::Spec::TestNumber',
  predicate => 'has_number',
);

=attr description

B<Optional>: Test description.

=cut

has 'description' => (
  is => 'rw',
  isa => 'Str',
  predicate => 'has_description',
);

=attr directive

B<Optional>: A test directive (SKIP or TODO).

=cut

has 'directive' => (
  is => 'rw',
  isa => 'TAP::Spec::Directive',
  predicate => 'has_directive',
);

=attr reason

B<Optional>: A reason associated with the directive.

=cut

has 'reason' => (
  is => 'rw',
  isa => 'Str',
  predicate => 'has_reason',
);

=method $result->passed

Whether the test is considered to have passed. A test passes if its status
is 'ok' or if it is a TODO test.

=cut

sub passed {
    my $self = shift;

    return 1 if $self->status eq 'ok';
    return 1 if $self->directive and $self->directive eq 'TODO';
    return '';
}

=method $result->as_tap

TAP representation.

=cut

sub as_tap {
  my ($self) = @_;

  my $tap = $self->status;
  $tap .= " " . $self->number if $self->has_number;
  $tap .= " " . $self->description if $self->has_description;
  if ($self->has_directive) {
    $tap .= " # " . $self->directive;
    $tap .= " " . $self->reason if $self->has_reason;
  }
  $tap .= "\n";
  return $tap;
}

__PACKAGE__->meta->make_immutable;
