package TAP::Spec::Parser;
# ABSTRACT: Reference implementation of the TAP specification
use strict;
use warnings;

use Regexp::Grammars 1.008;
use TAP::Spec::TestSet ();

my $tap_grammar = qr~
# Main production
<testset>

# Definitions from first grammar section

# Testset         = Header (Plan Body / Body Plan) Footer
<objtoken: TAP::Spec::TestSet=testset> 
  <header> (?: <plan> <body> | <body> <plan> ) <footer>

# Header          = [Comments] [Version]
<objtoken: TAP::Spec::Header=header> 
  <comments>? <version>?

# Footer          = [Comments]
<objtoken: TAP::Spec::Footer=footer> 
  <comments>?

# Body            = *(Comment / TAP-Line)
<objtoken: TAP::Spec::Body=body> 
  (?: <[lines=comment]> | <[lines=tap_line]> )*

# TAP-Line        = Test-Result / Bail-Out
<token: tap_line> 
  <MATCH=test_result>
| <MATCH=bail_out>

# Version         = "TAP version" SP Version-Number EOL ; ie. "TAP version 13"
<objtoken: TAP::Spec::Version=version> 
  TAP <.sp> version <.sp> <version_number> <.eol>

# Version-Number  = Positive-Integer
<token: version_number> 
  <MATCH=positive_integer>

# Plan            = ( Plan-Simple / Plan-Todo / Plan-Skip-All ) EOL
<token: plan> 
  (?: <MATCH=plan_simple> | <MATCH=plan_todo> | <MATCH=plan_skip_all> ) <.eol>

# Plan-Simple     = "1.." Number-Of-Tests
<objtoken: TAP::Spec::Plan::Simple=plan_simple>
  1.. <number_of_tests>

# Plan-Todo       = Plan-Simple "todo" 1*(SP Test-Number) ";"  ; Obsolete
<objtoken: TAP::Spec::Plan::Todo=plan_todo>
  <plan_simple> todo (?: <.sp> <[skipped_tests=test_number]> )+ ;
  (?{ 
    $MATCH{number_of_tests} = $MATCH{plan_simple}{number_of_tests};
    delete $MATCH{plan_simple};
  })

# Plan-Skip-All   = "1..0" SP "skip" SP Reason
<objtoken: TAP::Spec::Plan::SkipAll=plan_skip_all>
  1..0 <.sp> skip <.sp> <reason>

# Reason          = String
<token: reason>
  <MATCH=string>

# Number-Of-Tests = 1*DIGIT               ; The number of tests contained in this stream
<token: number_of_tests>
  \d+

# Test-Number     = Positive-Integer      ; The sequence of a test result
<token: test_number>
  <MATCH=positive_integer>

# Test-Result     = Status [SP Test-Number] [SP Description]
#                    [SP "#" SP Directive [SP Reason]] EOL
<objtoken: TAP::Spec::TestResult=test_result>
  <status> (?: <.sp> <number=test_number> )? (?: <.sp> <description> )?
  (?: 
    <.sp> \# <.sp> <directive> 
    (?: <.sp> <reason>)? 
  )? <.eol>

# Status          = "ok" / "not ok"       ; Whether the test succeeded or failed
<token: status>
  ok
| not\ ok

# Description     = Safe-String           ; A description of this test.
<token: description>
  <MATCH=safe_string>

# Directive       = "SKIP" / "TODO"
<token: directive>
  SKIP
| TODO

# Bail-Out        = "Bail out!" [SP Reason] EOL
<objtoken: TAP::Spec::BailOut=bail_out>
  Bail out! (?: <.sp> <reason>)? <.eol>

# Comment         = "#" String EOL
<objtoken: TAP::Spec::Comment=comment>
  \# <text=string> <.eol>

# Comments        = 1*Comment
<token: comments>
  <[MATCH=comment]>+

# EOL              = LF / CRLF             ; Specific to the system producing the stream
<token: eol>
  \n
| \r\n

# Safe-String      = 1*(%x01-09 %x0B-0C %x0E-22 %x24-FF)  ; UTF8 without EOL or "#"
<token: safe_string>
  [\x01-\x09\x0b-\x0c\x0e-\x22\x24-\xff]+

# String           = 1*(Safe-String / "#")                ; UTF8 without EOL
<token: string>
  (?: <.safe_string> | \# )+

# Positive-Integer = ("1" / "2" / "3" / "4" / "5" / "6" / "7" / "8" / "9") *DIGIT
<token: positive_integer>
  [1-9][0-9]*

# Because of BNF "SP" and because backslash-space in regex is ugly :)
<token: sp>
  \x20
~x;

=method $parser->parse_from_string($input)

Return a parse the given string, and return a L<TAP::Spec::TestSet> if it can
be parsed as TAP, or C<undef> otherwise.

=cut

sub parse_from_string {
  my ($self, $input) = @_;
  $input =~ /$tap_grammar/ or return;
  return $/{testset};
}

=method $parser->parse_from_handle($fh)

As C<parse_from_string>, but read from a filehandle instead. This isn't
a streaming interface, just a convenience method that slurps the handle
and calls C<parse_from_string>.

=cut

sub parse_from_handle {
  my ($self, $fh) = @_;
  my $data = do { local $/; <$fh> };
  return $self->parse_from_string($data);
}

1;
