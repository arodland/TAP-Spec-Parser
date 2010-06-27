package TAP::Spec::TestResult;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

enum 'TAP::Spec::TestStatus' => ('ok', 'not ok');
enum 'TAP::Spec::Directive' => qw(SKIP TODO);
subtype 'TAP::Spec::TestNumber' => as 'Int', where { $_ > 0 };

has 'status' => (
  is => 'rw',
  isa => 'TAP::Spec::TestStatus',
  required => 1,
);

has 'number' => (
  is => 'rw',
  isa => 'TAP::Spec::TestNumber',
  predicate => 'has_number',
);

has 'description' => (
  is => 'rw',
  isa => 'Str',
  predicate => 'has_description',
);

has 'directive' => (
  is => 'rw',
  isa => 'TAP::Spec::Directive',
  predicate => 'has_directive',
);

has 'reason' => (
  is => 'rw',
  isa => 'Str',
  predicate => 'has_reason',
);

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
