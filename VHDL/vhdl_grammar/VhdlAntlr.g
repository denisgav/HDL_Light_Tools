//
//  Copyright (C) 2010-2014  Denis Gavrish
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

grammar VhdlAntlr;

options {
    memoize = true;
    output = AST;
    ASTLabelType = CommonTree;
    language='CSharp3';
    superClass = AbstractVhdlAntlrParser;
}

tokens {
    //-----------------------------------------------------------------
    // keywords
    //-----------------------------------------------------------------

    ABS           = 'abs';
    ACCESS        = 'access';
    AFTER         = 'after';
    ALIAS         = 'alias';
    ALL           = 'all';
    AND           = 'and';
    ARCHITECTURE  = 'architecture';
    ARRAY         = 'array';
    ASSERT        = 'assert';
    ATTRIBUTE     = 'attribute';
    BEGIN         = 'begin';
    BLOCK         = 'block';
    BODY          = 'body';
    BUFFER        = 'buffer';
    BUS           = 'bus';
    CASE          = 'case';
    COMPONENT     = 'component';
    CONFIGURATION = 'configuration';
    CONSTANT      = 'constant';
    DISCONNECT    = 'disconnect';
    DOWNTO        = 'downto';
    ELSE          = 'else';
    ELSIF         = 'elsif';
    END           = 'end';
    ENTITY        = 'entity';
    EXIT          = 'exit';
    FILE          = 'file';
    FOR           = 'for';
    FUNCTION      = 'function';
    GENERATE      = 'generate';
    GENERIC       = 'generic';
    GROUP         = 'group';
    GUARDED       = 'guarded';
    IF            = 'if';
    IMPURE        = 'impure';
    INERTIAL      = 'inertial';
    IN            = 'in';
    INOUT         = 'inout';
    IS            = 'is';
    LABEL         = 'label';
    LIBRARY       = 'library';
    LINKAGE       = 'linkage';
    LITERAL       = 'literal';
    LOOP          = 'loop';
    MAP           = 'map';
    MOD           = 'mod';
    NAND          = 'nand';
    NEW           = 'new';
    NEXT          = 'next';
    NOR           = 'nor';
    NOT           = 'not';
    NULLTOK       = 'null';
    OF            = 'of';
    ON            = 'on';
    OPEN          = 'open';
    OR            = 'or';
    OTHERS        = 'others';
    OUT           = 'out';
    PACKAGE       = 'package';
    PORT          = 'port';
    POSTPONED     = 'postponed';
    PROCEDURE     = 'procedure';
    PROCESS       = 'process';
    PURE          = 'pure';
    RANGETOK      = 'range';
    RECORD        = 'record';
    REGISTER      = 'register';
    REJECT        = 'reject';
    REM           = 'rem';
    REPORT        = 'report';
    RETURN        = 'return';
    ROL           = 'rol';
    ROR           = 'ror';
    SELECT        = 'select';
    SEVERITY      = 'severity';
    SHARED        = 'shared';
    SIGNAL        = 'signal';
    SLA           = 'sla';
    SLL           = 'sll';
    SRA           = 'sra';
    SRL           = 'srl';
    SUBTYPE       = 'subtype';
    THEN          = 'then';
    TO            = 'to';
    TRANSPORT     = 'transport';
    TYPE          = 'type';
    UNAFFECTED    = 'unaffected';
    UNITS         = 'units';
    UNTIL         = 'until';
    USE           = 'use';
    VARIABLE      = 'variable';
    WAIT          = 'wait';
    WHEN          = 'when';
    WHILE         = 'while';
    WITH          = 'with';
    XNOR          = 'xnor';
    XOR           = 'xor';

    //-----------------------------------------------------------------
    // symbols
    //-----------------------------------------------------------------

    DOUBLESTAR    = '**';
    LE            = '<=';
    GE            = '>=';
    ARROW         = '=>';
    NEQ           = '/=';
    VARASGN       = ':=';
    BOX           = '<>';
    DBLQUOTE      = '\"';
    SEMI          = ';';
    COMMA         = ',';
    AMPERSAND     = '&';
    LPAREN        = '(';
    RPAREN        = ')';
    LBRACKET      = '[';
    RBRACKET      = ']';
    COLON         = ':';
    MUL           = '*';
    DIV           = '/';
    PLUS          = '+';
    MINUS         = '-';
    LT            = '<';
    GT            = '>';
    EQ            = '=';
    BAR           = '|';
    EXCLAMATION   = '!';
    DOT           = '.';
    BACKSLASH     = '\\';

    AGGREGATE;
    ASSOCIATION_LIST;
    ATTRIBUTE_DECLARATION;
    ATTRIBUTE_SPECIFICATION;
    BINDING_INDICATION;
    BLOCK_CONFIGURATION;
    BLOCK_STATEMENT;
    CHOICES;
    COMPONENT_CONFIGURATION;
    COMPONENT_INSTANCE;
    COMPONENT_INSTANTIATION_STATEMENT;
    CONDITIONAL_SIGNAL_ASSIGNMENT_STATEMENT;
    CONDITIONAL_WAVEFORMS;
    CONFIGURATION_SPECIFICATION;
    CONSTRAINED_ARRAY_DEFINITION;
    DISCRETE_RANGE;
    ENTITY_STATEMENT;
    ENUMERATION_TYPE_DEFINITION;
    EXPRESSION;
    FILE_TYPE_DEFINITION;
    FULL_TYPE_DECLARATION;
    GENERIC_MAP;
    GROUP_DECLARATION;
    GROUP_TEMPLATE_DECLARATION;
    INCOMPLETE_TYPE_DECLARATION;
    INDEX_CONSTRAINT;
    INSTANTIATION_LIST;
    INTEGER_OR_FLOAT_TYPE_DEFINITION;
    INTERFACE_CONSTANT_DECLARATION;
    INTERFACE_FILE_DECLARATION;
    INTERFACE_SIGNAL_DECLARATION;
    INTERFACE_VARIABLE_DECLARATION;
    LABEL_STATEMENT;
    NAME;
    NAME_SELECTED_PART;
    NAME_INDEXED_PART;
    NAME_INDEXED_OR_SLICE_PART;
    NAME_SLICE_PART;
    NAME_ATTRIBUTE_PART;
    PACKAGE_BODY;
    PHYSICAL_LITERAL;
    PHYSICAL_TYPE_DEFINITION;
    PORT_MAP;
    PROCEDURE_CALL;
    QUALIFIED_EXPRESSION;
    RECORD_TYPE_DEFINITION;
    RESOLVED;
    SELECTED_SIGNAL_ASSIGNMENT_STATEMENT;
    SIGNAL_ASSIGNMENT_STATEMENT;
    SIGNAL_LIST;
    SIGNATURE;
    SUBPROGRAM_BODY;
    SUBPROGRAM_DECLARATION;
    SUBTYPE_INDICATION;
    UNCONDITIONAL_LOOP;
    UNCONSTRAINED_ARRAY_DEFINITION;
    VARIABLE_ASSIGNMENT_STATEMENT;
    WAVEFORM;
    WAVEFORM_ELEMENT;
}

//-------------------------------------------------------------------
// java headers
//-------------------------------------------------------------------

//-------------------------------------------------------------------
// java members
//-------------------------------------------------------------------

@lexer::members {
    public const int CHANNEL_COMMENT = 80;
}

@parser::header {
using VHDLParser.antlr;
}

//-------------------------------------------------------------------
// parser rules
//-------------------------------------------------------------------

abstract_literal
    :   BINANRY_BASED_INTEGER
    |   OCTAL_BASED_INTEGER
    |   HEXA_BASED_INTEGER
    |   DEC_BASED_INTEGER
    ;

access_type_definition
    :   ACCESS subtype_indication
        -> ^( ACCESS subtype_indication )
    ;

//actual_designator
//    : expression
//    | signal_variable_or_file=name
//    | OPEN
//    ;

actual_part
    :   expression
    |   OPEN
//      handled by expression:
//  |   signal_variable_or_file_function_name_or_type_mark=name
    ;

adding_operator
    :   PLUS
    |   MINUS
    |   AMPERSAND
    ;

aggregate
    :   LPAREN element_association ( COMMA element_association )* RPAREN
        -> ^( AGGREGATE element_association+ )
    ;

alias_declaration
    :   ALIAS alias_designator ( COLON subtype_indication )? IS name signature? SEMI
        -> ^( ALIAS alias_designator subtype_indication? name signature? )
    ;

alias_designator
    :   identifier
    |   CHARACTER_LITERAL
    |   operator_symbol=STRING_LITERAL
    ;

//subtype indications in allocators can only contain index_constraints
//original: NEW ( subtype_indication | qualified_expression )
allocator
    :   NEW n1=name_without_parens
        (
                n2=name_without_parens? index_constraint?
                //n1 and n2 reversed -> see subtype_indication
                -> ^( NEW ^( SUBTYPE_INDICATION $n2? $n1 index_constraint? ) )
            |   qualified_expression
                -> ^( NEW ^( QUALIFIED_EXPRESSION $n1 qualified_expression ) )
        )
    ;

//TODO: check repeated label

architecture_body
    :   ARCHITECTURE identifier OF entity=name IS
        adp=architecture_declarative_part?
        BEGIN
        asp=architecture_statement_part?
        END ARCHITECTURE? end_identifier? SEMI
        -> ^( ARCHITECTURE identifier $entity $adp? $asp? end_identifier? )
    ;
architecture_declarative_part
	:   block_declarative_item+
	;

architecture_statement_part
	:   concurrent_statement+
	;

//TODO: check
array_type_definition
    :   ARRAY!
        (
                (LPAREN index_subtype_definition)=> unconstrained_array_definition
            |   constrained_array_definition
        )
    ;

assertion
    :   ASSERT condition ( REPORT report=expression )? ( SEVERITY severity=expression )?
        -> ^( ASSERT condition ^( REPORT[] $report? ) ^( SEVERITY[] $severity? ) )
    ;

assertion_statement
    :   assertion SEMI
        -> assertion
    ;

association_element
    :   ( (formal_part ARROW)=> formal_part ARROW )? actual_part
        -> formal_part? actual_part
    ;

association_list
    :   association_element ( COMMA association_element )*
        -> ^( ASSOCIATION_LIST association_element+ )
    ;

attribute_declaration
    :   ATTRIBUTE identifier COLON type_mark=name SEMI
        -> ^( ATTRIBUTE_DECLARATION identifier $type_mark )
    ;

//keyword "range" might be used as a attribte designator
attribute_designator
    :   attribute_simple_name=identifier
    |   RANGETOK -> BASIC_IDENTIFIER[$RANGETOK]
    ;

attribute_specification
    :   ATTRIBUTE attribute_designator OF entity_specification IS expression SEMI
        -> ^( ATTRIBUTE_SPECIFICATION attribute_designator entity_specification expression )
    ;

binding_indication
    :   ( USE entity_aspect )? generic_map_aspect? port_map_aspect?
        -> entity_aspect? generic_map_aspect? port_map_aspect?
    ;

block_configuration
    :   FOR block_specification
        use_clause*
        configuration_item*
        END FOR SEMI
        -> ^( BLOCK_CONFIGURATION block_specification use_clause* configuration_item* )
    ;

block_declarative_item
    :   subprogram_body_or_declaration
    |   type_declaration
    |   subtype_declaration
    |   constant_declaration
    |   signal_declaration
    |   shared_variable_declaration=variable_declaration
    |   file_declaration
    |   alias_declaration
    |   component_declaration
    |   attribute_declaration
    |   attribute_specification
    |   configuration_specification
    |   disconnection_specification
    |   use_clause
    |   group_template_declaration
    |   group_declaration
    ;

block_declarative_part
    :   block_declarative_item+
    ;

block_header
    :   ( generic_clause ( generic_map_aspect SEMI )? )?
        ( port_clause ( port_map_aspect SEMI )? )?
        -> generic_clause? generic_map_aspect? port_clause? port_map_aspect?
    ;

//index_specification
//    : (discrete_range)=> discrete_range
//    | expression //static_expression
//    ;

// : architecture=name
// | block_statement_label=identifier
// | generate_statement_label=identifier ( LPAREN index_specification? RPAREN )?
block_specification
    :   name
    ;

//TODO: check repeated label
block_statement
    :   BLOCK ( LPAREN guard_expression=expression RPAREN )? IS?
        block_header
        bdp=block_declarative_part?
        BEGIN
        bsp=block_statement_part?
        END BLOCK end_identifier? SEMI
        -> ^( BLOCK_STATEMENT $guard_expression? IS? block_header? $bdp? $bsp? end_identifier? )
    ;

block_statement_part
    :   concurrent_statement+
    ;

case_statement
    :   CASE expression IS
        case_statement_alternative+
        END CASE end_identifier? SEMI
        -> ^( CASE expression? case_statement_alternative+ end_identifier? )
    ;

case_statement_alternative
    :   WHEN choices ARROW sequence_of_statements
        -> choices sequence_of_statements?
    ;

choice
    :   simple_expression 
        (
                direction simple_expression
                -> ^( direction simple_expression simple_expression )
            |
                -> simple_expression
        )
//TODO: add
//    |   type_mark=name_without_parens constraint?
//        -> ^( DISCRETE_RANGE $type_mark constraint? )
    |   OTHERS
//      handled by simple_expression:
//  |   element_simple_name=identifier
    ;

choices
    :   choice ( ( BAR | EXCLAMATION ) choice )*
        -> ^( CHOICES choice+ )
    ;

component_configuration
    :   FOR cs=component_specification
        ( bi=binding_indication SEMI )?
        bc=block_configuration?
        END FOR SEMI
        -> ^( COMPONENT_CONFIGURATION $cs $bi? $bc? )
    ;

//TODO: check repeated label
component_declaration
    :   COMPONENT identifier IS?
        local_generic_clause=generic_clause?
        local_port_clause=port_clause?
        END COMPONENT end_identifier? SEMI
        -> ^( COMPONENT identifier IS? $local_generic_clause? $local_port_clause? end_identifier? )
    ;

component_instantiation_statement
    :   iu=instantiated_unit
        gma=generic_map_aspect?
        pma=port_map_aspect? SEMI
        -> ^( COMPONENT_INSTANTIATION_STATEMENT $iu $gma? $pma? )
    ;

component_specification
    :   instantiation_list COLON component=name
        -> instantiation_list $component
    ;

composite_type_definition
    :   array_type_definition
    |   record_type_definition
    ;

concurrent_assertion_statement
    :   assertion SEMI
        -> assertion
    ;

concurrent_procedure_call_statement
    :   procedure_call SEMI
        -> procedure_call
    ;

//a procedure call statement might be a component instantiation
concurrent_statement
    :   (
            identifier COLON
            (
                    (concurrent_statement_optional_label)=> concurrent_statement_optional_label
                    -> ^( LABEL_STATEMENT identifier concurrent_statement_optional_label )
                |   concurrent_statement_with_label
                    -> ^( LABEL_STATEMENT identifier concurrent_statement_with_label )
            )
        )
    |   concurrent_statement_optional_label
    ;

concurrent_statement_with_label
    :   block_statement
    |   component_instantiation_statement
    |   generate_statement
    ;

concurrent_statement_optional_label
    :   POSTPONED s=concurrent_statement_optional_label_2
        -> ^( POSTPONED $s )
    |   concurrent_statement_optional_label_2
    ;

concurrent_statement_optional_label_2
    :   process_statement
    |   (target LE)=> conditional_signal_assignment
    |   (concurrent_procedure_call_statement)=> concurrent_procedure_call_statement
    |   concurrent_assertion_statement
    |   selected_signal_assignment
    ;

condition
    :   bolean_expression=expression
    ;

condition_clause
    :   UNTIL condition
        -> ^( UNTIL condition )
    ;

conditional_signal_assignment
    :   target LE sao=signal_assignment_options cw=conditional_waveforms SEMI
        -> ^( CONDITIONAL_SIGNAL_ASSIGNMENT_STATEMENT target $sao? $cw )
    ;

conditional_waveforms
    :   waveform ( WHEN condition ( ELSE conditional_waveforms2 )? )?
        -> ^( CONDITIONAL_WAVEFORMS waveform condition? conditional_waveforms2? )
    ;

conditional_waveforms2
    :   waveform ( WHEN condition ( ELSE conditional_waveforms2 )? )?
        -> waveform condition? conditional_waveforms2?
    ;

//TODO: check repeated label
configuration_declaration
    :   CONFIGURATION identifier OF entity=name IS
        cdp=configuration_declarative_part?
        bc=block_configuration
        END CONFIGURATION? end_identifier? SEMI
        -> ^( CONFIGURATION identifier $entity $cdp? $bc end_identifier? )
    ;

configuration_declarative_item
    :   use_clause
    |   attribute_specification
    |   group_declaration
    ;

configuration_declarative_part
    :   configuration_declarative_item+
    ;

configuration_item
    :   block_configuration
    |   component_configuration
    ;

configuration_specification
    :   FOR component_specification binding_indication SEMI
        -> ^( CONFIGURATION_SPECIFICATION component_specification binding_indication? )
    ;

constant_declaration
    :   CONSTANT identifier_list COLON subtype_indication ( VARASGN expression )? SEMI
        -> ^( CONSTANT identifier_list subtype_indication expression? )
    ;

 constrained_array_definition
    :   index_constraint OF element_subtype_indication=subtype_indication
        -> ^( CONSTRAINED_ARRAY_DEFINITION index_constraint $element_subtype_indication )
    ;

constraint
    :   range_constraint
    |   index_constraint
    ;

context_clause
    :   context_item*
    ;

context_item
    :   library_clause
    |   use_clause
    ;

delay_mechanism
    :   TRANSPORT                	-> ^(TRANSPORT)                 //транспортная
    |   ( REJECT expression )? INERTIAL -> ^( INERTIAL expression? )    //инерционная или смешаная
    ;

public
design_file
    :   design_unit* EOF
    ;

design_unit
    :   context_clause (primary_unit|secondary_unit)
    ;

designator
    :   identifier
    |   operator_symbol=STRING_LITERAL
    ;

direction
    :   TO
    |   DOWNTO
    ;

disconnection_specification
    :   DISCONNECT guarded_signal_specification AFTER time_expression=expression SEMI
        -> ^( DISCONNECT guarded_signal_specification $time_expression )
    ;

//discrete_range
//    : discrete_subtype_indication
//    | range
//    ;
// subtpye_indication can't contain a resolve function
discrete_range
    :   (simple_expression direction)=> simple_expression direction simple_expression
        -> ^( direction simple_expression simple_expression )
    |   type_mark=name_without_parens constraint?
        -> ^( DISCRETE_RANGE $type_mark constraint? )
    ;

element_association
    :   ( (choices ARROW)=> choices ARROW )? expression
        -> choices? expression
    ;

element_declaration
    :   identifier_list COLON element_subtype_indication=subtype_indication SEMI
        -> identifier_list $element_subtype_indication
    ;

entity_aspect
    :   ENTITY entity=name_without_parens ( LPAREN architecture=identifier RPAREN )?
        -> ^( ENTITY $entity $architecture? )
    |   CONFIGURATION configuration=name
        -> ^( CONFIGURATION $configuration )
    |   OPEN
    ;

entity_class
    :   ENTITY
    |   ARCHITECTURE
    |   CONFIGURATION
    |   PROCEDURE
    |   FUNCTION
    |   PACKAGE
    |   TYPE
    |   SUBTYPE
    |   CONSTANT
    |   SIGNAL
    |   VARIABLE
    |   COMPONENT
    |   LABEL
    |   LITERAL
    |   UNITS
    |   GROUP
    |   FILE
    ;

entity_class_entry
    :   entity_class BOX?
    ;

entity_class_entry_list
    :   entity_class_entry ( COMMA entity_class_entry )*
        -> entity_class_entry+
    ;

//TODO: check repeated label
entity_declaration
    :   ENTITY identifier IS
        entity_header
        entity_declarative_part?
        ( BEGIN entity_statement_part? )?
        END ENTITY? end_identifier? SEMI
        -> ^( ENTITY identifier entity_header? entity_declarative_part? entity_statement_part? end_identifier? )
    ;

entity_declarative_item
    :   subprogram_body_or_declaration
    |   type_declaration
    |   subtype_declaration
    |   constant_declaration
    |   signal_declaration
    |   shared_variable_declaration=variable_declaration
    |   file_declaration
    |   alias_declaration
    |   attribute_declaration
    |   attribute_specification
    |   disconnection_specification
    |   use_clause
    |   group_template_declaration
    |   group_declaration
    ;

entity_declarative_part
    :   entity_declarative_item+
    ;

entity_designator
    :   entity_tag signature?
    ;

entity_header
    :   formal_generic_clause=generic_clause?
        formal_port_clause=port_clause?
    ;

entity_name_list
    :   entity_designator ( COMMA entity_designator )*
        -> entity_designator+
    |   OTHERS
    |   ALL
    ;

entity_specification
    :   entity_name_list COLON entity_class
        -> entity_name_list entity_class
    ;

entity_statement
    :   ( identifier COLON )? POSTPONED? entity_statement2
        -> ^( ENTITY_STATEMENT identifier? POSTPONED? entity_statement2 )
    ;

entity_statement2
    :   concurrent_assertion_statement
    |   concurrent_procedure_call_statement
    |   process_statement
    ;

entity_statement_part
    :   entity_statement+
    ;

entity_tag
    :   simple_name=identifier
    |   CHARACTER_LITERAL
    |   operator_symbol=STRING_LITERAL
    ;

enumeration_literal
    :   CHARACTER_LITERAL
    |   identifier
    ;

enumeration_type_definition
    :   LPAREN enumeration_literal ( COMMA enumeration_literal )* RPAREN
        -> ^( ENUMERATION_TYPE_DEFINITION enumeration_literal+ )
    ;

exit_statement
    :   EXIT loop_label=identifier? ( WHEN condition )? SEMI
        -> ^( EXIT $loop_label? condition? )
    ;

expression
    :   expression2
        -> ^( EXPRESSION expression2 )
    ;

expression2
    :   relation ( logical_operator^ relation )*
    ;

factor
    :   primary ( DOUBLESTAR^ primary )?
    |   ABS primary
        -> ^( ABS primary )
    |   NOT primary
        -> ^( NOT primary )
    ;

file_declaration
    :   FILE identifier_list COLON subtype_indication file_open_information? SEMI
        -> ^( FILE identifier_list subtype_indication file_open_information? )
    ;

file_logical_name
    :   string_expression=expression
    ;

file_open_information
    :   ( OPEN file_open_kind=expression )? IS file_logical_name
        -> ^(OPEN $file_open_kind )? file_logical_name
    ;

file_type_definition
    :   FILE OF type_mark=name
        -> ^( FILE_TYPE_DEFINITION $type_mark )
    ;

//formal_designator
//    : generic_port_or_parameter=name
//    ;

//formal_part
//    : formal_designator
//    | function_or_type_mark=name //( LPAREN formal_designator RPAREN )?
formal_part
    :   name
    ;

full_type_declaration
    :   TYPE identifier IS type_definition SEMI
        -> ^( FULL_TYPE_DECLARATION identifier type_definition )
    ;

//TODO: check repeated label
generate_statement
    :   generation_scheme
        GENERATE
        ( block_declarative_item* BEGIN )?
        concurrent_statement*
        END GENERATE end_identifier? SEMI
        -> ^( GENERATE generation_scheme block_declarative_item* concurrent_statement* end_identifier? )
    ;

generation_scheme
    :   FOR generate_parameter_specification=parameter_specification
    |   IF condition
    ;

generic_clause
    :   GENERIC LPAREN generic_interface_list RPAREN SEMI
        -> ^( GENERIC generic_interface_list )
    ;

generic_interface_list
    :   interface_constant_declaration_optional_class
        ( SEMI interface_constant_declaration_optional_class )*
        -> interface_constant_declaration_optional_class+
    ;

generic_map_aspect
    :   GENERIC MAP LPAREN generic_association_list=association_list RPAREN
        -> ^( GENERIC_MAP $generic_association_list )
    ;

group_constituent
    :   name
    |   CHARACTER_LITERAL
    ;

group_constituent_list
    :   group_constituent ( COMMA group_constituent )*
        -> group_constituent
    ;

group_declaration
    :   GROUP identifier COLON group_template_name=name_without_parens
        LPAREN group_constituent_list RPAREN SEMI
        -> ^( GROUP_DECLARATION identifier $group_template_name group_constituent_list )
    ;

group_template_declaration
    :   GROUP identifier IS LPAREN entity_class_entry_list RPAREN SEMI
        -> ^( GROUP_TEMPLATE_DECLARATION identifier entity_class_entry_list )
    ;

guarded_signal_specification
    :   guarded_signal_list=signal_list COLON type_mark=name
        -> signal_list name
    ;

identifier
    :   BASIC_IDENTIFIER
    |   EXTENDED_IDENTIFIER
    ;
 end_identifier
 	:	identifier;

identifier_list
    :   identifier ( COMMA identifier )*
        -> identifier+
    ;

//TODO: check repeated label
if_statement
    :   IF condition THEN
        sos=sequence_of_statements
        if_statement_elsif_part*
        isep=if_statement_else_part?
        END IF end_identifier? SEMI
        -> ^( IF condition $sos? if_statement_elsif_part* $isep? end_identifier? )
    ;

if_statement_elsif_part
    :   ELSIF condition THEN sequence_of_statements
        -> ^( ELSIF condition sequence_of_statements? )
    ;

if_statement_else_part
    :   ELSE sequence_of_statements
        -> ^( ELSE sequence_of_statements? )
    ;

incomplete_type_declaration
    :   TYPE identifier SEMI
        -> ^( INCOMPLETE_TYPE_DECLARATION identifier )
    ;

index_constraint
    :   LPAREN discrete_range ( COMMA discrete_range )* RPAREN
        -> ^( INDEX_CONSTRAINT discrete_range+ )
    ;

index_subtype_definition
    :   type_mark=name RANGETOK BOX
        -> $type_mark
    ;

instantiated_unit
    :   COMPONENT? component=name_without_parens
        -> ^( COMPONENT_INSTANCE COMPONENT? $component )
    |   ENTITY entity=name_without_parens ( LPAREN architecture=identifier RPAREN )?
        -> ^( ENTITY $entity $architecture? )
    |   CONFIGURATION configuration=name_without_parens
        -> ^( CONFIGURATION $configuration )
    ;

instantiation_list
    :   instantiation_label1=identifier ( COMMA instantiation_label2=identifier )*
        -> ^( INSTANTIATION_LIST identifier+ )
    |   OTHERS
    |   ALL
    ;

//integer_type_definition and floating_type_defintion were merged
//because they have the same syntax
integer_or_floating_type_definition
    :   range_constraint
        -> ^( INTEGER_OR_FLOAT_TYPE_DEFINITION range_constraint )
    ;

interface_ambigous_declaration_procedure
    :   identifier_list COLON
        (
                IN? si1=subtype_indication ( VARASGN static_expression1=expression )?
                -> ^( INTERFACE_CONSTANT_DECLARATION identifier_list IN? $si1 $static_expression1? )
            |   ( m=OUT | m=INOUT ) si2=subtype_indication ( VARASGN static_expression2=expression )?
                -> ^( INTERFACE_VARIABLE_DECLARATION identifier_list $m $si2 $static_expression2? )
        )
    ;

//made contant not optional. ambigous case is handled separately.
interface_constant_declaration
    :   CONSTANT identifier_list COLON IN? subtype_indication
        ( VARASGN static_expression=expression )?
        -> ^( INTERFACE_CONSTANT_DECLARATION CONSTANT identifier_list IN? subtype_indication
                $static_expression? )
    ;

interface_constant_declaration_optional_class
    :   CONSTANT? identifier_list COLON IN? subtype_indication
        ( VARASGN static_expression=expression )?
        -> ^( INTERFACE_CONSTANT_DECLARATION CONSTANT? identifier_list IN? subtype_indication
                $static_expression? )
    ;

interface_element_function
    :   interface_constant_declaration_optional_class
    |   interface_signal_declaration
    |   interface_variable_declaration
    |   interface_file_declaration
    ;

interface_element_procedure
    :   interface_constant_declaration
    |   interface_signal_declaration
    |   interface_variable_declaration
    |   interface_file_declaration
    |   interface_ambigous_declaration_procedure
    ;

interface_file_declaration
    :   FILE identifier_list COLON subtype_indication
        -> ^( INTERFACE_FILE_DECLARATION FILE identifier_list subtype_indication )
    ;

//made signal not optional. ambigous case is handled separately.
interface_signal_declaration
    :   SIGNAL identifier_list COLON mode? subtype_indication BUS?
        ( VARASGN static_expression=expression )?
        -> ^( INTERFACE_SIGNAL_DECLARATION SIGNAL identifier_list mode? subtype_indication
                BUS? $static_expression? )
    ;

interface_signal_declaration_for_port
    :   SIGNAL? identifier_list COLON mode? subtype_indication BUS?
        ( VARASGN static_expression=expression )?
        -> ^( INTERFACE_SIGNAL_DECLARATION SIGNAL? identifier_list mode? subtype_indication
                BUS? $static_expression? )
    ;

//made variable not optional. ambigous case is handled separately.
interface_variable_declaration
    :   VARIABLE identifier_list COLON mode? subtype_indication
        ( VARASGN static_expression=expression )?
        -> ^( INTERFACE_VARIABLE_DECLARATION VARIABLE identifier_list mode? subtype_indication
                $static_expression? )
    ;

iteration_scheme
    :   WHILE condition
        -> ^( WHILE condition )
    |   FOR loop_parameter_specification=parameter_specification
        -> ^( FOR $loop_parameter_specification )
    |   //inserted imaginary token to fix parsing of empty loops
        -> UNCONDITIONAL_LOOP
    ;

library_clause
    :   LIBRARY logical_name_list SEMI
        -> ^( LIBRARY logical_name_list )
    ;

logical_name_list
    :   logical_name1=identifier ( COMMA logical_name2=identifier )*
        -> identifier+
    ;

logical_operator
    :   AND
    |   OR
    |   NAND
    |   NOR
    |   XOR
    |   XNOR
    ;

//TODO: check repeated label
loop_statement
    :   iteration_scheme
        LOOP
        sequence_of_statements
        END LOOP end_identifier? SEMI
        -> ^( LOOP iteration_scheme sequence_of_statements? end_identifier? )
    ;

mode
    :   IN
    |   OUT
    |   INOUT
    |   BUFFER
    |   LINKAGE
    ;

multiplying_operator
    :   MUL
    |   DIV
    |   MOD
    |   REM
    ;

name
    :   name_prefix ( (name_part)=> name_part )*
        -> ^( NAME name_prefix name_part* )
    ;

name_with_association
    :   name_prefix name_with_association_part*
        -> ^( NAME name_prefix name_with_association_part* )
    ;

name_without_parens
    :   name_prefix name_without_parens_part*
        -> ^( NAME name_prefix name_without_parens_part* )
    ;

name_part
    :   name_selected_part
    |   (LPAREN name constraint? RPAREN)=>
        LPAREN name
        (
                constraint
                -> ^( NAME_SLICE_PART ^( DISCRETE_RANGE name constraint ) )
            |
                -> ^( NAME_INDEXED_OR_SLICE_PART name )
        )
        RPAREN
    |   LPAREN expression
        (
                direction expression
                -> ^( NAME_SLICE_PART ^( direction expression expression ) )
            |   ( COMMA expression )*
            -> ^( NAME_INDEXED_PART expression+ )
        )
        RPAREN
    |   name_attribute_part
;

name_with_association_part
    :   name_selected_part
    |   (LPAREN name constraint? RPAREN)=>
        LPAREN name
        (
                constraint
                -> ^( NAME_SLICE_PART ^( DISCRETE_RANGE name constraint ) )
            |
                -> ^( NAME_INDEXED_OR_SLICE_PART name )
        )
        RPAREN
    |   LPAREN
        (
                (expression direction)=> expression direction expression
                -> ^( NAME_SLICE_PART ^( direction expression expression ) )
            |   association_list
                -> association_list
        )
        RPAREN
    |   name_attribute_part
    ;

name_without_parens_part
    :   name_selected_part
    |   name_attribute_part
    ;

name_prefix
    :   simple_name=identifier
    |   operator_symbol=STRING_LITERAL
    ;

name_selected_part
    :   DOT suffix
        -> ^( NAME_SELECTED_PART suffix )
    ;

name_attribute_part
    :   signature? APOSTROPHE attribute_designator
        ( (LPAREN expression RPAREN)=> LPAREN expression RPAREN )?
        -> ^( NAME_ATTRIBUTE_PART signature? attribute_designator expression? )
    ;

next_statement
    :   NEXT loop_label=identifier? ( WHEN condition )? SEMI
        -> ^( NEXT $loop_label? condition? )
    ;

null_statement
    :   NULLTOK SEMI
        -> NULLTOK
    ;

//was named options, renamed because options is an ANTLR keyword
signal_assignment_options
    :   GUARDED? delay_mechanism?
    ;

//TODO: check repeated label
package_body
    :   PACKAGE BODY identifier IS
        package_body_declarative_part?
        END ( PACKAGE BODY )? end_identifier? SEMI
        -> ^( PACKAGE_BODY identifier? package_body_declarative_part? end_identifier?)
    ;

package_body_declarative_item
    :   subprogram_body_or_declaration
    |   type_declaration
    |   subtype_declaration
    |   constant_declaration
    |   shared_variable_declaration=variable_declaration
    |   file_declaration
    |   alias_declaration
    |   use_clause
    |   group_template_declaration
    |   group_declaration
    ;

package_body_declarative_part
    :   package_body_declarative_item+
    ;

//TODO: check repeated label
package_declaration
    :   PACKAGE identifier IS
        package_declarative_part?
        END PACKAGE? end_identifier? SEMI
        -> ^( PACKAGE identifier package_declarative_part? end_identifier? )
    ;

package_declarative_item
    :   subprogram_declaration
    |   type_declaration
    |   subtype_declaration
    |   constant_declaration
    |   signal_declaration
    |   shared_variable_declaration=variable_declaration
    |   file_declaration
    |   alias_declaration
    |   component_declaration
    |   attribute_declaration
    |   attribute_specification
    |   disconnection_specification
    |   use_clause
    |   group_template_declaration
    |   group_declaration
    ;

package_declarative_part
    :   package_declarative_item+
    ;

parameter_interface_list_function
    :   interface_element_function ( SEMI interface_element_function )*
        -> interface_element_function+
    ;

parameter_interface_list_procedure
    :   interface_element_procedure ( SEMI interface_element_procedure )*
        -> interface_element_procedure+
    ;

parameter_specification
    :   identifier IN discrete_range
        -> identifier discrete_range
    ;

//TODO: check repeated label
physical_type_definition
    :   range_constraint UNITS
        primary_unit_declaration=identifier SEMI
        secondary_unit_declaration*
        END UNITS end_identifier?
        -> ^( PHYSICAL_TYPE_DEFINITION range_constraint $primary_unit_declaration 
                secondary_unit_declaration* identifier end_identifier? )
    ;

port_clause
    :   PORT LPAREN port_interface_list RPAREN SEMI
        -> ^( PORT port_interface_list )
    ;

port_interface_list
    :   interface_signal_declaration_for_port ( SEMI interface_signal_declaration_for_port )*
        -> interface_signal_declaration_for_port+
    ;

port_map_aspect
    :   PORT MAP LPAREN port_association_list=association_list RPAREN
        -> ^( PORT_MAP $port_association_list )
    ;

//numeric_literal
//    : abstract_literal
//    | physical_literal
//    ;
//
//physical_literal
//    : abstract_literal? unit=name -> literal without unit handled by name
//    ;
//
//literal
//    : numeric_literal
//    | enumeration_literal -> handled by name and CHARACTER_LITERAL
//    | CHARACTER_LITERAL
//    | STRING_LITERAL -> handled by name
//    | BIT_STRING_LITERAL
//    | NULLTOK
//    ;
//
//primary ::=
//        name
//      | literal
//      | aggregate
//      | function_call
//      | qualified_expression
//      | type_conversion -> handled by name
//      | allocator
//      | ( expression ) -> handled by aggregate

primary
    :   abstract_literal
    (     identifier
	         -> ^(PHYSICAL_LITERAL abstract_literal identifier )
	  |
	  	-> abstract_literal
    )
    |	FLOAT_POINT_LITERAL
    |   CHARACTER_LITERAL    
    |   BIT_STRING_LITERAL_BINARY
    |   BIT_STRING_LITERAL_OCTAL
    |   BIT_STRING_LITERAL_HEX
    |   NULLTOK
    |   aggregate
    |   allocator
    |   type_mark_name_or_function=name_with_association
        (
                qualified_expression
                -> ^( QUALIFIED_EXPRESSION $type_mark_name_or_function qualified_expression )
            |
                -> $type_mark_name_or_function
        )
    ;

primary_unit
    :
    entity_declaration
    |   configuration_declaration
    |   package_declaration
    ;

procedure_call
    :   procedure=name_without_parens ( LPAREN parameters=association_list RPAREN )?
        -> ^( PROCEDURE_CALL $procedure $parameters? )
//procedure=name ( LPAREN actual_parameter_part RPAREN )?
    ;

procedure_call_statement
    :   procedure_call SEMI
        -> procedure_call
    ;

process_declarative_item
    :   subprogram_body_or_declaration
    |   type_declaration
    |   subtype_declaration
    |   constant_declaration
    |   variable_declaration
    |   file_declaration
    |   alias_declaration
    |   attribute_declaration
    |   attribute_specification
    |   use_clause
    |   group_template_declaration
    |   group_declaration
    ;

process_declarative_part
    :   process_declarative_item+
    ;

//TODO: check repeated label
process_statement
    :   PROCESS ( LPAREN sensitivity_list RPAREN )? IS?
        process_declarative_part?
        BEGIN
        process_statement_part?
        END POSTPONED? PROCESS end_identifier? SEMI
        -> ^( PROCESS sensitivity_list? IS? process_declarative_part? process_statement_part? end_identifier? POSTPONED?)
    ;

process_statement_part
    :   sequential_statement+
    ;

//moved type_mark out of this rule to remove ambiguity
//type_mark APOSTROPHE ( LPAREN expression RPAREN | aggregate )
qualified_expression
    :   APOSTROPHE aggregate
        -> aggregate
    ;

range
    :   (simple_expression direction)=> simple_expression direction^ simple_expression
    |   range_attribute=name
    ;

range_constraint
    :   RANGETOK range
        -> ^( RANGETOK range )
    ;

//TODO: check repeated label
record_type_definition
    :   RECORD
        element_declaration+
        END RECORD identifier?
        -> ^( RECORD_TYPE_DEFINITION element_declaration+ )
    ;

relation
    :   shift_expression ( relational_operator^ shift_expression )?
    ;

relational_operator
    :   EQ
    |   NEQ
    |   LT
    |   LE
    |   GT
    |   GE
    ;

report_statement
    :   REPORT report=expression ( SEVERITY severity=expression )? SEMI
        -> ^( REPORT $report $severity? )
    ;

return_statement
    :   RETURN expression? SEMI
        -> ^( RETURN expression? )
    ;

scalar_type_definition
    :   enumeration_type_definition
    |   (range_constraint UNITS)=> physical_type_definition
    |   integer_or_floating_type_definition
    ;

secondary_unit
    :   architecture_body
    |   package_body
    ;

secondary_unit_declaration
    :   identifier EQ abstract_literal? unit=name SEMI
        -> identifier abstract_literal? $unit
    ;

selected_signal_assignment
    :   WITH expression SELECT target LE sao=signal_assignment_options sw=selected_waveforms SEMI
        -> ^( SELECTED_SIGNAL_ASSIGNMENT_STATEMENT expression target $sao? $sw )
    ;

selected_waveform
    :   waveform WHEN choices
        -> waveform choices
    ;

selected_waveforms
    :   selected_waveform ( COMMA selected_waveform )*
        -> selected_waveform+
    ;

sensitivity_clause
    :   ON sensitivity_list
        -> ^( ON sensitivity_list )
    ;

sensitivity_list
    :   signal=name ( COMMA signal=name )*
        -> name+
    ;

sequence_of_statements
    :   sequential_statement*
    ;

//moved labels from individual statement rules to
//sequential statements to make rules LL(*)
sequential_statement
    :   identifier COLON s=sequential_statement_2
        -> ^( LABEL_STATEMENT identifier $s )
    |   sequential_statement_2
    ;

sequential_statement_2
    :   wait_statement
    |   assertion_statement
    |   report_statement
    |   (target LE)=> signal_assignment_statement
    |   (target VARASGN)=> variable_assignment_statement
    |   procedure_call_statement
    |   if_statement
    |   case_statement
    |   loop_statement
    |   next_statement
    |   exit_statement
    |   return_statement
    |   null_statement
    ;

shift_expression
    :   simple_expression2 ( shift_operator^ simple_expression2 )?
    ;

shift_operator
    :   SLL
    |   SRL
    |   SLA
    |   SRA
    |   ROL
    |   ROR
    ;

sign
    :   PLUS
    |   MINUS
    ;

signal_assignment_statement
    :   target LE delay_mechanism? waveform SEMI
        -> ^( SIGNAL_ASSIGNMENT_STATEMENT target delay_mechanism? waveform )
    ;

signal_declaration
    :   SIGNAL identifier_list COLON subtype_indication signal_kind? ( VARASGN expression )? SEMI
        -> ^( SIGNAL identifier_list subtype_indication signal_kind? expression? )
    ;

signal_kind
    :   REGISTER
    |   BUS
    ;

signal_list
    :   signal=name ( COMMA signal=name )*
        -> ^( SIGNAL_LIST name+ )
    |   OTHERS
    |   ALL
    ;

signature
    :   LBRACKET signature_type_marks? ( RETURN return_type=name )? RBRACKET
        -> ^( SIGNATURE signature_type_marks? ( RETURN $return_type )? )
    ;

signature_type_marks
    :   name ( COMMA name )*
        -> name+
    ;

simple_expression
    :   simple_expression2
        -> ^( EXPRESSION simple_expression2 )
    ;

simple_expression2
    :   sign? term ( adding_operator^ term )*
    ;

//merged subprogram_declaration and subprogram_body rules to make them LL(*)
//
//subprogram_body
//    : subprogram_specification IS
//      subprogram_declarative_part
//      BEGIN
//      subprogram_statement_part
//      END subprogram_kind? designator? SEMI
//    ;
//

subprogram_declaration
    :   subprogram_specification SEMI
        -> ^( SUBPROGRAM_DECLARATION subprogram_specification )
    ;

subprogram_body_part
    :   IS
        subprogram_declarative_part?
        BEGIN
        subprogram_statement_part?
        END subprogram_kind? designator?
        -> subprogram_declarative_part? subprogram_statement_part?
    ;

subprogram_body_or_declaration
    :   subprogram_specification
        (
                subprogram_body_part
                -> ^( SUBPROGRAM_BODY subprogram_specification subprogram_body_part? )
            |
                -> ^( SUBPROGRAM_DECLARATION subprogram_specification )
        )
        SEMI
    ;

subprogram_declarative_item
    :   subprogram_body_or_declaration
    |   type_declaration
    |   subtype_declaration
    |   constant_declaration
    |   variable_declaration
    |   file_declaration
    |   alias_declaration
    |   attribute_declaration
    |   attribute_specification
    |   use_clause
    |   group_template_declaration
    |   group_declaration
    ;

subprogram_declarative_part
    :   subprogram_declarative_item+
    ;

subprogram_kind
    :   PROCEDURE
    |   FUNCTION
    ;

subprogram_specification
    :   PROCEDURE designator ( LPAREN parameter_interface_list_procedure RPAREN )?
        -> ^( PROCEDURE designator parameter_interface_list_procedure? )
    |   ( PURE | IMPURE )? FUNCTION designator
        ( LPAREN parameter_interface_list_function RPAREN )? RETURN type_mark=name
        -> ^( FUNCTION PURE? IMPURE? designator $type_mark parameter_interface_list_function? )
    ;

subprogram_statement_part
    :   sequential_statement+
    ;

subtype_declaration
    :   SUBTYPE identifier IS subtype_indication SEMI
        -> ^( SUBTYPE identifier subtype_indication )
    ;

//one name: type_mark
//two names: 1. resolution_function
//           2. type_mark
//AST: type_mark always the first name
subtype_indication
    :   n1=name_without_parens n2=name_without_parens? constraint?
        -> ^( SUBTYPE_INDICATION $n2? $n1 constraint? )
    ;

suffix
    :   simple_name=identifier
    |   CHARACTER_LITERAL
    |   operator_symbol=STRING_LITERAL
    |   ALL
    ;

target
    :   name
    |   aggregate
    ;

term
    :   factor ( multiplying_operator^ factor )*
    ;

timeout_clause
    :   FOR time=expression
        -> ^( FOR $time)
    ;

type_declaration
    :   full_type_declaration
    |   incomplete_type_declaration
    ;

type_definition
    :   scalar_type_definition
    |   composite_type_definition
    |   access_type_definition
    |   file_type_definition
    ;

unconstrained_array_definition
    :   LPAREN index_subtype_definition ( COMMA index_subtype_definition )* RPAREN
        OF element_subtype_indication=subtype_indication
        -> ^( UNCONSTRAINED_ARRAY_DEFINITION index_subtype_definition+ $element_subtype_indication )
    ;

use_clause
    :   USE selected_name1=name ( COMMA selected_name2=name )* SEMI
        -> ^( USE name+ )
    ;

variable_assignment_statement
    :   target VARASGN expression SEMI
        -> ^( VARIABLE_ASSIGNMENT_STATEMENT target expression )
    ;

variable_declaration
    :   SHARED? VARIABLE identifier_list COLON subtype_indication ( VARASGN expression )? SEMI
        -> ^( VARIABLE SHARED? identifier_list subtype_indication expression? )
    ;

wait_statement
    :   WAIT sensitivity_clause? condition_clause? timeout_clause? SEMI
        -> ^( WAIT sensitivity_clause? condition_clause? timeout_clause? )
    ;

waveform
    :   waveform_element ( COMMA waveform_element )*
        -> ^( WAVEFORM waveform_element+ )
    |   UNAFFECTED
    ;

waveform_element
    :   expression ( AFTER expression )?
        -> ^( WAVEFORM_ELEMENT expression expression? )
//( value_expression | NULLTOK ) ( AFTER time_expression )?
//removed NULLTOK: NULLTOK is an expression
    ;

//-------------------------------------------------------------------
// lexer rules
//-------------------------------------------------------------------

WHITESPACE
    :   ( '\t' | ' ' | '\n' | '\r' )+ { $channel = Hidden; }
    ;

COMMENT
    :   '--' ( ~( '\n' | '\r' ) )* { $channel = CHANNEL_COMMENT; }
    ;

BASIC_IDENTIFIER
    :   LETTER ( LETTER_OR_DIGIT | '_' )*
    ;

//extended identifiers can't contain a single backslash
EXTENDED_IDENTIFIER
    :   '\\' ( '\"' | '\\\\' | '%'  | GRAPHIC_CHARACTER )+ '\\'
    ;

FLOAT_POINT_LITERAL
	: DEC_BASED_INTEGER ('.' (DIGIT)+) EXPONENT?
	;


//added synpreds to fix "signal integer range 0 to 1:=0"
//DECIMAL_LITERAL
//    :   INTEGER
//        (
//                ( '.' INTEGER )? EXPONENT?
//            |   ('#' BASED_INTEGER ( '.' BASED_INTEGER )? '#' EXPONENT?)=>
//                '#' BASED_INTEGER ( '.' BASED_INTEGER )? '#' EXPONENT?
//                { $type = BASED_LITERAL; }
//            |   (':' BASED_INTEGER ( '.' BASED_INTEGER )? ':' EXPONENT?)=>
//                ':' BASED_INTEGER ( '.' BASED_INTEGER )? ':' EXPONENT?
//                { $type = BASED_LITERAL; }
//        )
//    ;

//added check for ambigous case (e.g abc'(bit'('0'), 1, true))
//TODO: check if there are more cases that need to be handled
APOSTROPHE
    :     '\''
        | { state.type != BASIC_IDENTIFIER && state.type != EXTENDED_IDENTIFIER }?=>
            ( '\''
                (
                    (( '\"' | '\\' | '%' | GRAPHIC_CHARACTER ) '\'')=>
                        ( '\"' | '\\' | '%' | GRAPHIC_CHARACTER ) '\''
                        { $type = CHARACTER_LITERAL; }
                )?
            )
    ;

//string literals can't contain a single quotation mark
STRING_LITERAL
    :   '\"' ( '\"\"' | '\\' | '%' | GRAPHIC_CHARACTER )* '\"'
    |   '%'  ( '%%' | '\\' | GRAPHIC_CHARACTER )* '%'
    ;

BIT_STRING_LITERAL_BINARY
    :   'b' '\"' ('1' | '0' | '_')+ '\"'
    |   'b' '%'  ('1' | '0' | '_')+ '%'
    ;

BIT_STRING_LITERAL_OCTAL
    :   'o' '\"' ('7' |'6' |'5' |'4' |'3' |'2' |'1' | '0' | '_')+ '\"'
    |   'o' '%'  ('7' |'6' |'5' |'4' |'3' |'2' |'1' | '0' | '_')+ '%'
    ;

BIT_STRING_LITERAL_HEX
    :   'x' '\"' ( 'f' |'e' |'d' |'c' |'b' |'a' | 'F' |'E' |'D' |'C' |'B' |'A' | '9' | '8' | '7' |'6' |'5' |'4' |'3' |'2' |'1' | '0' | '_')+ '\"'
    |   'x' '%'  ( 'f' |'e' |'d' |'c' |'b' |'a' | 'F' |'E' |'D' |'C' |'B' |'A' | '9' | '8' | '7' |'6' |'5' |'4' |'3' |'2' |'1' | '0' | '_')+ '%'
    ;



BINANRY_BASED_INTEGER
:
	'2' '#' ('1' | '0' | '_')+ '#' (DEC_BASED_INTEGER)?
	;

	

OCTAL_BASED_INTEGER
:
	'8' '#' ('7' |'6' |'5' |'4' |'3' |'2' |'1' | '0' | '_')+ '#' (DEC_BASED_INTEGER)?
	;
	

HEXA_BASED_INTEGER
:
	'16' '#' ( 'f' |'e' |'d' |'c' |'b' |'a' | 'F' |'E' |'D' |'C' |'B' |'A' | '9' | '8' | '7' |'6' |'5' |'4' |'3' |'2' |'1' | '0' | '_')+ '#' (DEC_BASED_INTEGER)?
	;


DEC_BASED_INTEGER
	:   DIGIT
	|   ('1'..'9') (DIGIT | '_')+ 
	;


EXPONENT
    :   ('e'|'E') ('-'|'+')? DEC_BASED_INTEGER
    ;

fragment
LETTER_OR_DIGIT
    :   LETTER
    |   DIGIT
    ;

fragment
LETTER
    :   UPPER_CASE_LETTER
    |   LOWER_CASE_LETTER
    //|	HEXA_INTEGER_LITERAL
    ;

fragment
GRAPHIC_CHARACTER
    :   UPPER_CASE_LETTER
    |   DIGIT
    |   SPECIAL_CHARACTER
    |   SPACE_CHARACTER
    |   LOWER_CASE_LETTER
    |   OTHER_SPECIAL_CHARACTER
    ;

fragment
UPPER_CASE_LETTER
    :   'A'..'Z' | '\u00c0'..'\u00d6' | '\u00d8' .. '\u00de'
    ;

fragment
LOWER_CASE_LETTER
    :   'a'..'z' | '\u00df'..'\u00f6' | '\u00f8'.. '\u00ff'
    ;

fragment
DIGIT
    :   '0'..'9'
    ;

//removed " from SPECIAL_CHARACTER to handle separately in different contexts
fragment
SPECIAL_CHARACTER
    :   '#' | '&' | '\'' | '(' | ')' | '*' | '+' | ',' | '-'
    |   '.' | '/' | ':' | ';' | '<' | '=' | '>' | '[' | ']' | '_' | '|'
    ;

fragment
SPACE_CHARACTER
    :   ' ' | '\u00a0'
    ;

//removed \ and % from OTHER_SPECIAL_CHARACTER to handle separately in different contexts
fragment
OTHER_SPECIAL_CHARACTER
    :   '!' | '$' | '@' | '?' | '^' | '`' | '{' | '}' | '~'
    |   '\u00a1'..'\u00bf' | '\u00d7' | '\u00f7'
    ;

//----------------------------------------------------------------------
// dummy rules to remove ANTLR warnings
//----------------------------------------------------------------------
fragment
CHARACTER_LITERAL
    :
    ;

fragment
BASED_LITERAL
    : 
    ;
