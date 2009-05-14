=begin comments

OCarrot::Grammar::Actions - ast transformations for OCarrot

This file contains the methods that are used by the parse grammar
to build the PAST representation of an OCarrot program.
Each method below corresponds to a rule in F<src/parser/grammar.pg>,
and is invoked at the point where C<{*}> appears in the rule,
with the current match object as the first argument.  If the
line containing C<{*}> also has a C<#= key> comment, then the
value of the comment is passed as the second argument to the method.

=end comments
=cut

class OCarrot::Grammar::Actions;

method TOP($/, $key) {
    our $?BLOCK;
    our @?BLOCK;
    if $key eq 'begin' {
        $?BLOCK := PAST::Block.new( :blocktype('immediate'), :node($/));
        @?BLOCK.unshift($?BLOCK);
    }
    else {
        my $past := @?BLOCK.shift();
        $past.push($( $/{$key} ));
        make $past;
    }
}

method integer_literal($/) {
  make PAST::Val.new( :value( ~$/), :returns('Integer'), :node($/));
}

method float_literal($/) {
  make PAST::Val.new( :value( ~$/), :returns('Float'), :node($/));
}

method string_constant($/) {
  make PAST::Val.new( :value( $($<string_literal>) ), :returns('String'), :node($/));
}

method definition($/, $key) {
  if $key eq 'let' {
  }
  else {
  }
}

method number($/, $key) {
  make $( $/{$key} );
}

method constant($/, $key) {
  if $key eq 'constr'  {
  }
  elsif $key eq 'true' {
    # TODO Type booléen
    make PAST::Val.new( :value('1'), :returns('Integer'), :node($/));
  }
  elsif $key eq 'false' {
    make PAST::Val.new( :value('0'), :returns('Integer'), :node($/));
  }
  elsif $key eq 'unit' {
  }
  elsif $key eq 'empty_list' {
    make PAST::Val.new( :returns('ResizablePMCArray'), :node($/));
  }
  elsif $key eq 'variant' {
  }
  else {
    make $( $/{$key} );
  }
}

method seq_expr($/) {
  my $past := PAST::Stmts.new( :node($/));
  for $<expr> {
    $past.push($($_));
  }
  make $past;
}

method expr($/, $key) {
  if $key eq 'let_in' {
    my $block := PAST::Block.new( :blocktype('immediate'), :node($/));
    for $<let_binding> {
      $block.push( $( $_ ) );
    }
    $block.push( $( $<seq_expr> ) );

    make $block;
  }
  else {
    make $( $/{$key} );
  }
}

method op_expression($/, $key) {
  if ($key eq 'end') {
    make $($<expr>);
  }
  else {
    my $past := PAST::Op.new( :name($<type>),
                              :pasttype($<top><pasttype>),
                              :pirop($<top><pirop>),
                              :lvalue($<top><lvalue>),
                              :node($/)
                            );
    for @($/) {
        $past.push( $($_) );
    }
    make $past;
  }
}

method primary_expression($/) {
  if $<args> {
    my $past := PAST::Op.new($($<simple_expression>),
      :pasttype('call'), :node($/));
    for $<args> {
      $past.push($($_));
    }
    make $past;
  }
  else {
    make $( $<simple_expression> );
  }
}

method simple_expression($/, $key) {
  if $key eq 'array' {
    my $past := PAST::Op.new( :name('%array'), :pasttype('call'), :node($/) );
    for $<expr> {
      $past.push($($_));
    }
    make $past;
  }
  elsif $key eq 'list' {
    my $past := PAST::Op.new( :name('%list'), :pasttype('call'), :node($/) );
    for $<expr> {
      $past.push($($_));
    }
    make $past;
  }
  elsif $key eq 'value_path' {
    my $past := PAST::Var.new( :name(~$<value_path>), :scope('package'),
      :node($<value_path>));
    make $past;
  }
  else {
    make $( $/{$key} );
  }
}

method let_binding($/, $key) {
  if $key eq 'value' {
    #TODO c'est un motif !
    my $lhs := PAST::Var.new( :name(~$<value_path>), :scope('package'),
                              :lvalue('1'), :node($<value_path>));
    my $rhs := $( $<expr> );
    make PAST::Op.new($lhs, $rhs, :pasttype('bind'), :node($/));
  }
  elsif $key eq 'function' {
    my $fn := PAST::Block.new( :name(~$<value_name>),
                              :blocktype('declaration'), :node($/) );
    for $<parameter> {
      my $param := $( $_ );
      $param.scope('parameter');
      $fn.push($param);
      $fn.symbol($param.name(), :scope('lexical'));
    }

    $fn.push( $( $<expr> ) );
    make $fn;
  }
}

method parameter($/) {
  make PAST::Var.new( :name(~$<value_name>), :scope('lexical'), :node($/));
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

