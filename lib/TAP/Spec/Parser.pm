package TAP::Spec::Parser;
# ABSTRACT: Reference implementation of the TAP specification
use Mouse;
use Method::Signatures::Simple;
use Try::Tiny;
use Parser::MGC 0.07 ();
extends 'Parser::MGC';

#use Devel::TraceCalls { Package => ['TAP::Spec::Parser', 'Parser::MGC'] };

use TAP::Spec::TestSet ();

# Tell MGC never to skip whitespace without being told.
sub pattern_ws {
  qr/(?!)/
}

=method TAP::Spec::Parser->parse_from_string($string)

Attempt to parse a TAP TestSet from C<$string>. Returns a L<TAP::Spec::TestSet>
on success, throws an exception on failure.

=cut

# API adapters to MGC
method parse_from_string ($class: $string) {
  $class->new->from_string($string);
}

=method TAP::Spec::Parser->parse_from_handle($handle)

Like C<parse_from_string> only accepts an opened filehandle.

=cut

method parse_from_handle ($class: $handle) {
  $class->new->from_reader(sub {
      scalar <$handle>
    });
}

=method TAP::Spec::Parser->parse_from_file($filename)

Like C<parse_from_string> only accepts the name of a file to read a TAP
stream from.

=cut

method parse_from_file ($class: $file) {
  $class->new->from_file($file);
}

# Weird helper stuff
method maybe_attr ($hash, $attr, $code) {
  my $ret = $self->maybe($code);
  if (defined $ret) {
    $hash->{$attr} = $ret;
  }
}

method seq_of ($code) {
  my @ret;

  my $done;

  while (! $self->at_eos && !$done) {
    try {
      push @ret, $code->($self);
    } catch {
      if ($_->isa('Parser::MGC::Failure')) {
        $done = 1;
      } else {
        die $_;
      }
    }
  }

  return \@ret;
}

sub lookahead
{
  my $self = shift;
  my ( $code ) = @_;

  my $pos = pos $self->{str};

  my $success = eval { $code->( $self ); 1 };
  my $e = $@;

  pos $self->{str} = $pos;

  if (!$success) {
    die $e if not eval { $e->isa( "Parser::MGC::Failure" ) };
  }

  return $success;
}

# This should include any rule defined below that matches a complete valid
# line of TAP. Any line *not* matched by this rule will be consumed as junk by
# parse_junk_line.
method parse_nonjunk_line {
  $self->any_of(
    sub { $self->parse_comment },
    sub { $self->parse_version },
    sub { $self->parse_tap_line },
    sub { $self->parse_plan },
  );
}

# Match any line of input that *couldn't* be matched by another line
# rule and save it in a JunkLine object
method parse_junk_line {
  $self->lookahead(sub { $self->parse_nonjunk_line }) and $self->fail;
  my $text = $self->expect(qr/[^\n]*/);
  $self->_eol;
  TAP::Spec::JunkLine->new(text => $text);
}

method maybe_junk {
  $self->seq_of(
    sub {
      $self->parse_junk_line;
    }
  );
}

method maybe_junk_attr($hash, $attr, @code) {
  $self->maybe_attr($hash, $attr, 
    sub { $self->maybe_junk }
  );
}

### Below is grammar

# Main production
method parse {
  $self->parse_testset;
}

# Testset         = Header (Plan Body / Body Plan) Footer
method parse_testset {
  my %tmp;
  $tmp{header} = $self->parse_header;
  $self->any_of(
    sub {
      $tmp{plan} = $self->parse_plan;
      $tmp{body} = $self->parse_body;
    },
    sub {
      $tmp{body} = $self->parse_body;
      $tmp{plan} = $self->parse_plan;
    }
  );
  $tmp{footer} = $self->parse_footer;
  TAP::Spec::TestSet->new(%tmp);
}

# Header          = [Comments] [Version]
method parse_header {
  my %tmp;
  # This is very twisty, but incidental to the way the grammar works. It's all
  # in the fact that the spec says "All unparsable lines must be ignored by TAP
  # consumers". For the sake of completeness we're not totally ignoring but
  # capturing them, with the "parse_junk_line" method. Which means that any
  # time we're about to match a complete line of TAP, we need to give a junk
  # line a chance to match first using 'maybe_junk_attr', which does a
  # lookahead to see if the next line is valid TAP and if not, eats input
  # line-by-line until it is.

  $self->maybe_junk_attr(\%tmp, 'leading_junk');

  $self->maybe_attr(\%tmp, 'comments',
    sub { $self->parse_comments }
  );
  $self->maybe_junk_attr(\%tmp, 'junk_before_version');

  $self->maybe_attr(\%tmp, 'version',
    sub { $self->parse_version }
  );

  $self->maybe_junk_attr(\%tmp, 'trailing_junk');

  TAP::Spec::Header->new(%tmp);
}

# Footer          = [Comments]
method parse_footer {
  my %tmp;

  $self->maybe_junk_attr(\%tmp, 'leading_junk');

  $self->maybe_attr(\%tmp, 'comments',
    sub { $self->parse_comments }
  );

  $self->maybe_junk_attr(\%tmp, 'trailing_junk');

  TAP::Spec::Footer->new(%tmp);
}

# Body            = *(Comment / TAP-Line)
method parse_body {
  my $lines = $self->seq_of(
    sub {
      $self->any_of(
        sub { $self->parse_comment },
        sub { $self->parse_tap_line },
        sub { $self->parse_junk_line },
      );
    }
  );
  TAP::Spec::Body->new(lines => $lines);
}

# TAP-Line        = Test-Result / Bail-Out 
method parse_tap_line {
  $self->any_of(
    sub { $self->parse_test_result },
    sub { $self->parse_bail_out },
  );
}

# Version         = "TAP version" SP Version-Number EOL ; ie. "TAP version 13"
method parse_version {
  $self->expect(qr/TAP version /i);
  my $verno = $self->parse_version_number;
  $self->_eol;
  TAP::Spec::Version->new(version_number => $verno);
}

# Version-Number  = Positive-Integer
method parse_version_number {
  $self->parse_positive_integer;
}

# Plan            = ( Plan-Simple / Plan-Todo / Plan-Skip-All ) EOL
method parse_plan {
  my $plan = $self->any_of(
    sub { $self->parse_plan_simple },
    sub { $self->parse_plan_todo },
    sub { $self->parse_plan_skip_all },
  );
  $self->_eol;
  return $plan;
}

# Plan-Simple     = "1.." Number-Of-Tests
method parse_plan_simple {
  $self->expect('1..');
  TAP::Spec::Plan::Simple->new(number_of_tests => $self->parse_number_of_tests);
}

# Plan-Todo       = Plan-Simple "todo" 1*(SP Test-Number) ";"  ; Obsolete
method parse_plan_todo {
  my $plan_simple = $self->parse_plan_simple;
  $self->expect(qr/todo/i);
  my $skipped_tests = $self->seq_of(
    sub {
      $self->_sp;
      $self->parse_test_number;
    }
  );
  TAP::Spec::Plan::Todo->new(
    number_of_tests => $plan_simple->number_of_tests,
    skipped_tests => $skipped_tests,
  );
}

# Plan-Skip-All   = "1..0" SP "skip" SP Reason
method parse_plan_skip_all {
  $self->expect('1..0');
  $self->_sp;
  $self->expect(qr/skip/i);
  $self->_sp;
  TAP::Spec::Plan::SkipAll->new(
    reason => $self->parse_reason,
  );
}

# Reason          = String
method parse_reason {
  $self->parse_string;
}

# Number-Of-Tests = 1*DIGIT               ; The number of tests contained in this stream
method parse_number_of_tests {
  $self->expect(qr/\d+/);
}

# Test-Number     = Positive-Integer      ; The sequence of a test result
method parse_test_number {
  $self->parse_positive_integer;
}

# Test-Result     = Status [SP Test-Number] [SP Description]                                                                                                  
#                    [SP "#" SP Directive [SP Reason]] EOL
method parse_test_result {
  my %tmp;
  $tmp{status} = $self->parse_status;
  $self->maybe_attr(\%tmp, 'number',
    sub {
      $self->_sp;
      $self->parse_test_number;
    }
  );
  $self->maybe_attr(\%tmp, 'description',
    sub {
      $self->_sp;
      $self->parse_description;
    }
  );
  $self->maybe_attr(\%tmp, 'directive',
    sub {
      $self->_sp;
      $self->expect('#');
      $self->_sp;
      my $directive = $self->parse_directive;
      $tmp{reason} = $self->maybe(
        sub {
          $self->_sp;
          $self->parse_reason;
        }
      );
      return $directive;
    }
  );
  $self->_eol;
  TAP::Spec::TestResult->new(%tmp);
}

# Status          = "ok" / "not ok"       ; Whether the test succeeded or failed
method parse_status {
  $self->any_of(
    sub { $self->expect(qr/ok/i); return "ok" },
    sub { $self->expect(qr/not ok/i); return "not ok" },
  );
}

# Description     = Safe-String           ; A description of this test.
method parse_description {
  $self->parse_safe_string;
}

# Directive       = "SKIP" / "TODO"
method parse_directive {
  $self->any_of(
    sub { $self->expect(qr/SKIP/i); return "SKIP" },
    sub { $self->expect(qr/TODO/i); return "TODO" },
  );
}

# Bail-Out        = "Bail out!" [SP Reason] EOL
method parse_bail_out {
  $self->expect(qr/Bail out!/i);
  my $reason = $self->maybe(
    sub {
      $self->_sp;
      $self->parse_reason;
    }
  );
  $self->_eol;
  TAP::Spec::BailOut->new( reason => $reason );
}

# Comment         = "#" String EOL
method parse_comment {
  $self->expect("#");
  my $text = $self->parse_string;
  $self->_eol;
  TAP::Spec::Comment->new( text => $text );
}

# Comments        = 1*Comment
method parse_comments {
  $self->seq_of(
    sub { $self->parse_comment }
  );
}

# EOL              = LF / CRLF             ; Specific to the system producing the stream
method _eol {
  $self->expect(qr/\n|\r\n/);
}

# Safe-String      = 1*(%x01-09 %x0B-0C %x0E-22 %x24-FF)  ; UTF8 without EOL or "#"
method parse_safe_string {
  $self->expect(qr/[\x01-\x09\x0b-\x0c\x0e-\x22\x24-\xff]+/);
}

# String           = 1*(Safe-String / "#")                ; UTF8 without EOL
method parse_string {
  my $bits = $self->seq_of(
    sub {
      $self->any_of(
        sub { $self->parse_safe_string },
        sub { $self->expect('#') },
      );
    }
  );
  join '', @$bits;
}

# Positive-Integer = ("1" / "2" / "3" / "4" / "5" / "6" / "7" / "8" / "9") *DIGIT
method parse_positive_integer {
  $self->expect(qr/[1-9][0-9]*/);
}

method _sp {
  $self->expect(' ');
}

no Mouse;
1;
__END__

=head1 DESCRIPTION

This module is part of the effort to turn the Test Anything Protocol into an
IETF-approved internet standard. It's not optimized for production use (although
people might find it useful); instead it's meant as a running embodiment of the
TAP grammar in the draft standard, allowing the grammar to be comprehensively
tested.

=head1 SEE ALSO

=over 4

=item * L<http://testanything.org/wiki/index.php/TAP_at_IETF:_Draft_Standard>

=back

=cut
