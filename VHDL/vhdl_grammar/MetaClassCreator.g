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

tree grammar MetaClassCreator;

options {
    tokenVocab = VhdlAntlr;
    ASTLabelType = CommonTree;
    language='CSharp3';
    superClass = AbstractMetaClassCreator;
}

@header {
    using VHDL;
    using VHDL.annotation;
    using VHDL.parser;
    using VHDL.parser.annotation;
    using VHDL.concurrent;
    using VHDL.configuration;
    using VHDL.declaration;
    using VHDL.expression;
    using VHDL.libraryunit;
    using VHDL.literal;
    using VHDL.Object;
    using VHDL.statement;
    using VHDL.type;
    using System;
    using VHDL.parser.antlr;
}

@members {
    public MetaClassCreator(ITreeNodeStream input, VhdlParserSettings settings,
            RootDeclarativeRegion rootScope, LibraryDeclarativeRegion libraryScope, VHDL_Library_Manager libraryManager)
        :base(input, settings, rootScope, libraryScope, libraryManager)
         {}

    private bool inElementAssociation = false;
}

abstract_literal returns [AbstractLiteral value]
@after { AddAnnotations($value, $start); }
    :   DEC_BASED_INTEGER 	{ $value = new DecBasedInteger($DEC_BASED_INTEGER.text); }
    |	BINANRY_BASED_INTEGER	{ $value = new BinaryBasedInteger($BINANRY_BASED_INTEGER.text); }
    |   OCTAL_BASED_INTEGER	{ $value = new OctalBasedInteger($OCTAL_BASED_INTEGER.text); }
    |   HEXA_BASED_INTEGER	{ $value = new HexBasedInteger($HEXA_BASED_INTEGER.text); }
    
    
    ;

access_type_definition[string ident] returns [AccessType value]
@after { AddAnnotations($value, $start); }
    :   ^( ACCESS subtype_indication )
        { $value = new AccessType($ident, $subtype_indication.value); }
    ;

adding_operator returns [ExpressionType value]
    :   PLUS      { $value = ExpressionType.ADD; }
    |   MINUS     { $value = ExpressionType.SUB; }
    |   AMPERSAND { $value = ExpressionType.CONCAT; }
    ;

aggregate returns [Aggregate value = new Aggregate()]
@init { bool hasChoices; }
@after { AddAnnotations($value, $start); }
    :   ^( AGGREGATE
            (
                {
                    hasChoices = false;
                    inElementAssociation = true;
                }
                ( choices { hasChoices = true;} )?
                { inElementAssociation = false; }
                expression
                {
                    if (hasChoices) {
                        $value.CreateAssociation($expression.value, $choices.value);
                    } else {
                        $value.CreateAssociation($expression.value);
                    }
                }
            )+
        )
    ;

//TODO: don't use name.text
alias_declaration returns [Alias value]
@after { AddAnnotations($value, $start); }
    :   ^( ALIAS
            alias_designator subtype_indication? name
            { $value = new Alias($alias_designator.value, $subtype_indication.value, $name.text); }
            ( signature { $value.Signature = $signature.value; } )?
        )
        
    ;

//TODO: handle different literal types?
alias_designator returns [string value]
@after { $value = $alias_designator.text; }
    :   identifier
    |   CHARACTER_LITERAL
    |   STRING_LITERAL
    ;

allocator returns [Expression value]
@after { AddAnnotations($value, $start); }
    :   ^( NEW
            (
                    subtype_indication
                    { $value = new SubtypeIndicationAllocator($subtype_indication.value); }
                |   qualified_expression
                    { $value = new QualifiedExpressionAllocator($qualified_expression.value); }
            )
        )
    ;

architecture_body [List<LibraryUnit> contextItems] returns [Architecture value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
    AddAnnotations($value, $architecture_body.start);
}
    :   ^( ARCHITECTURE
            identifier entity=name
            {
                $value = new Architecture($identifier.text, $entity.value.toEntity(currentScope));
                $value.Parent = oldScope;
                currentScope = $value;
                $value.ContextItems.AddRange(contextItems);
            	contextItems.Clear();
            }
            ( d=block_declarative_item { $value.Declarations.Add($d.value); } )*
            { AddListEndComments($d.value, $d.start); }
            ( s=concurrent_statement { $value.Statements.Add($s.value); } )*
            { AddListEndComments($s.value, $s.start); }
	    end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($value.Identifier, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_ARCHITECTURE, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $value.Identifier));
            }
        )
    ;

assertion_statement[string label] returns [AssertionStatement value]
@after { AddAnnotations($value, $start); }
    :   ^( ASSERT
            condition=expression          { $value = new AssertionStatement($condition.value); }
            { $value.Label = $label; }
            ^( REPORT rep=expression? )   { $value.ReportedExpression = $rep.value; }
            ^( SEVERITY sev=expression? ) { $value.Severity = $sev.value; }
        )
    ;

//TODO: check
association_element returns [AssociationElement value]
@after { AddAnnotations($value, $start); }
    :   formal=name
        (
                actual=expression { $value = new AssociationElement($formal.text, $actual.value); }
            |   OPEN              { $value = new AssociationElement($formal.text, null); }
        )
    |   actual=expression { $value = new AssociationElement($actual.value); }
    |   OPEN              { $value = new AssociationElement(null); }
    ;

association_list returns [List<AssociationElement> value = new List<AssociationElement>()]
    :   ^( ASSOCIATION_LIST 
            ( e=association_element { $value.Add($e.value); } )+
        )
    ;

attribute_declaration returns [VHDL.declaration.Attribute value]
@after { AddAnnotations($value, $start); }
    :   ^( ATTRIBUTE_DECLARATION identifier type_mark=name )
        { $value = new VHDL.declaration.Attribute($identifier.text, $type_mark.value.toTypeMark(currentScope)); }
    ;

//TODO: remove dummy attribute
attribute_designator returns [VHDL.declaration.Attribute value]
@after { AddAnnotations($value, $start); }
    :   identifier { $value = new VHDL.declaration.Attribute($identifier.text, UnresolvedType.NO_NAME); }
    ;

attribute_specification returns [VHDL.declaration.AttributeSpecification value]
@after { AddAnnotations($value, $start); }
    :   ^( ATTRIBUTE_SPECIFICATION attribute_designator entity_name_list entity_class expression )
        {
            $value = new VHDL.declaration.AttributeSpecification($attribute_designator.value,
                $entity_name_list.value, $entity_class.value, $expression.value);
        }
    ;

block_configuration returns [AbstractBlockConfiguration value]
@after { AddAnnotations($value, $start); }
    :   ^( BLOCK_CONFIGURATION
            block_specification { $value = $block_specification.value; }
            ( uc=use_clause { $value.UseClauses.Add($uc.value); } )*
            ( ci=configuration_item { $value.ConfigurationItems.Add($ci.value); } )*
        )
    ;

block_declarative_item returns [IBlockDeclarativeItem value]
    :   subprogram_declaration      { $value = $subprogram_declaration.value; }
    |   subprogram_body             { $value = $subprogram_body.value; }
    |   type_declaration            { $value = $type_declaration.value; }
    |   subtype_declaration         { $value = $subtype_declaration.value; }
    |   constant_declaration        { $value = $constant_declaration.value; }
    |   signal_declaration          { $value = $signal_declaration.value; }
    |   variable_declaration        { $value = $variable_declaration.value; }
    |   file_declaration            { $value = $file_declaration.value; }
    |   alias_declaration           { $value = $alias_declaration.value; }
    |   component_declaration       { $value = $component_declaration.value; }
    |   attribute_specification     { $value = $attribute_specification.value; }
    |   attribute_declaration       { $value = $attribute_declaration.value; }
    |   configuration_specification { $value = $configuration_specification.value; }
    |   disconnection_specification { $value = $disconnection_specification.value; }
    |   use_clause                  { $value = $use_clause.value; }
    |   group_template_declaration  { $value = $group_template_declaration.value; }
    |   group_declaration           { $value = $group_declaration.value; }
    ;

//TODO: check
block_specification returns [AbstractBlockConfiguration value]
@after { AddAnnotations($value, $start); }
    : name
        {
            Architecture dummy = new Architecture($name.text, new Entity("##dummy##"));
            $value = new ArchitectureConfiguration(dummy);
        }
    ;

//annotations handled in concurrent_statement
block_statement[String label] returns [BlockStatement value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
}
    :   ^( BLOCK_STATEMENT
            {
                $value = new BlockStatement($label);
                $value.Parent = oldScope;
                currentScope = $value;
            }
            ( guard_expression=expression { $value.GuardExpression = $guard_expression.value; } )?
            (
                IS
                {
                    Annotations.putAnnotation($value,
                        new OptionalIsFormat(true));
                }
            )?
            ( gc=generic_clause { AddRange($value.Generic, $gc.value); } )?
            ( gma=generic_map_aspect { AddRange($value.GenericMap, $gma.value); } )?
            ( pc=port_clause { AddRange($value.Port, $pc.value); } )?
            ( pma=port_map_aspect { AddRange($value.PortMap, $pma.value); } )?
            ( bdi=block_declarative_item { $value.Declarations.Add($bdi.value); } )*
            { AddListEndComments($bdi.value, $bdi.start); }
            ( cs=concurrent_statement { $value.Statements.Add($cs.value); } )*
            { AddListEndComments($cs.value, $cs.start); }
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($label, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_OTHER, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $label));
            }
        )
    ;

case_statement[String label] returns [CaseStatement value]
@after { AddAnnotations($value, $start); }
    :   ^( CASE 
            expression { $value = new CaseStatement($expression.value); }
            { $value.Label = $label; }
            (
                choices 
                { CaseStatement.Alternative alt = $value.createAlternative($choices.value); }
                ( sequential_statement { alt.Statements.Add($sequential_statement.value); } )*
            )+
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($label, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_CASE, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $label));
            }
        )
    ;

choice returns [Choice value]
    :   discrete_range { $value = $discrete_range.value; }
    |   expression     { $value = $expression.value; }
    |   OTHERS         { $value = Choices.OTHERS; }
    ;

choices returns [List<Choice> value = new List<Choice>()]
    :   ^( CHOICES ( choice { $value.Add($choice.value); } )+ )
    ;

component_configuration returns [ComponentConfiguration value]
@after { AddAnnotations($value, $start); }
    :   ^( COMPONENT_CONFIGURATION
            component_specification
            { $value = new ComponentConfiguration($component_specification.value); }
            ( ea=entity_aspect { $value.EntityAspect = $ea.value; } )?
            ( gma=generic_map_aspect { AddRange($value.GenericMap, $gma.value); } )?
            ( pma=port_map_aspect { AddRange($value.PortMap, $pma.value); } )?
            ( bc=block_configuration { $value.BlockConfiguration = $bc.value; } )?
        )
    ;

component_declaration returns [Component value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
    AddAnnotations($value, $start);
}
    :   ^( COMPONENT 
            identifier
            {
                $value = new Component($identifier.text);
                $value.Parent = oldScope;
                currentScope = $value;
            }
            (
                IS
                {
                    Annotations.putAnnotation($value, 
                        new OptionalIsFormat(true));
                }
            )?
            ( gc=generic_clause { AddRange($value.Generic, $gc.value); } )?
            ( pc=port_clause { AddRange($value.Port, $pc.value); } )?
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($value.Identifier, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_COMPONENT, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $value.Identifier));
            }
        )
    ;

//annotations handled in concurrent_statement
component_instantiation_statement[string label] returns [AbstractComponentInstantiation value]
    :   ^( COMPONENT_INSTANTIATION_STATEMENT
            instantiated_unit[label] { $value = $instantiated_unit.value; }
            ( gma=generic_map_aspect { AddRange($value.GenericMap, $gma.value); } )?
            ( pma=port_map_aspect { AddRange($value.PortMap, $pma.value); } )?
        )
    ;

component_specification returns [ComponentSpecification value]
@init { List<String> identifiers = new List<String>(); }
@after { AddAnnotations($value, $start); }
    :   ^( INSTANTIATION_LIST ( identifier { identifiers.Add($identifier.text); } )+ )
        comp1=name
        {
            $value = ComponentSpecification.create($comp1.value.toComponent(currentScope),
                identifiers);
        }
    |   OTHERS comp2=name
        { $value = ComponentSpecification.createOthers($comp2.value.toComponent(currentScope)); }
    |   ALL comp3=name
        { $value = ComponentSpecification.createAll($comp3.value.toComponent(currentScope)); }
    ;

//annotations handled in concurrent_statement & entity_statement
concurrent_assertion_statement[string label] returns [ConcurrentAssertionStatement value]
    :   ^( ASSERT
            condition=expression
            {
                $value = new ConcurrentAssertionStatement($condition.value);
                $value.Label = $label;
            }
            ^( REPORT rep=expression? ) { $value.ReportedExpression = $rep.value; }
            ^( SEVERITY sev=expression? ) { $value.Severity = $sev.value; }
        )
    ;

//annotations handled in concurrent_statement & entity_statement
concurrent_procedure_call_statement[string label] returns [ConcurrentProcedureCall value]
    :   ^( PROCEDURE_CALL
            name
            {
                $value = new ConcurrentProcedureCall($name.value.toProcedure(currentScope));
                $value.Label = $label;
            }
            (
                parameters=association_list
                { AddRange($value.Parameters, $parameters.value); }
            )?
        )
    ;

//annotations handled in concurrent_statement
concurrent_signal_assignment_statement[string label] returns [AbstractPostponableConcurrentStatement value]
    :   ^( CONDITIONAL_SIGNAL_ASSIGNMENT_STATEMENT csa=conditional_signal_assignment )
        {
            $value = $csa.value;
            $value.Label = $label;
        }
    |   ^( SELECTED_SIGNAL_ASSIGNMENT_STATEMENT ssa=selected_signal_assignment)
        {
            $value = $ssa.value;
            $value.Label = $label;
        }
    ;

//annotations handled in concurrent_statement
conditional_signal_assignment returns [ConditionalSignalAssignment value]
@init {
    bool isGuarded = false;
    DelayMechanism delay = DelayMechanism.INERTIAL;
}
    :   ts=target_signal
    	( GUARDED { isGuarded = true; } )?
	( delay_mechanism {delay = $delay_mechanism.value;})?
        cw=conditional_waveforms
        {
            $value = new ConditionalSignalAssignment($ts.value, $cw.value);
            $value.Guarded = isGuarded;
            $value.DelayMechanism = delay;
        }
    ;

concurrent_statement returns [ConcurrentStatement value]
@after { AddAnnotations($value, $start); }
    :   ^( LABEL_STATEMENT identifier
            (
                    s1=concurrent_statement_optional_label[$identifier.text]
                    { $value = $s1.value; }
                |   s2=concurrent_statement_with_label[$identifier.text]
                    { $value = $s2.value; }
            )
        )
    |   s3=concurrent_statement_optional_label[null]
        { $value = $s3.value; }
    ;

concurrent_statement_optional_label[string label] returns [ConcurrentStatement value]
    :   statement1=concurrent_statement_optional_label2[$label, false]
        { $value = $statement1.value; }
    |   ^( POSTPONED statement2=concurrent_statement_optional_label2[$label, true] )
        {
            if ($statement2.value != null) {
                $statement2.value.Postponed = true;
            }
            $value = $statement2.value;
        }
    ;

concurrent_statement_optional_label2[string label, bool isPostponed] returns [AbstractPostponableConcurrentStatement value]
    :   ps=process_statement[$label, $isPostponed]                        { $value = $ps.value; }
    |   cpcs=concurrent_procedure_call_statement[$label]    { $value = $cpcs.value; }
    |   cas=concurrent_assertion_statement[$label]          { $value = $cas.value; }
    |   csas=concurrent_signal_assignment_statement[$label] { $value = $csas.value; }
    ;

concurrent_statement_with_label[string label] returns [ConcurrentStatement value]
    :   bs=block_statement[$label]                    { $value = $bs.value; }
    |   cis=component_instantiation_statement[$label] { $value = $cis.value; }
    |   gs=generate_statement[$label]                 { $value = $gs.value; }
    ;

//TODO: check
conditional_waveforms returns [List<ConditionalSignalAssignment.ConditionalWaveformElement> value = new List<ConditionalSignalAssignment.ConditionalWaveformElement>()]
    :   ^( CONDITIONAL_WAVEFORMS
            (
                w=waveform
                { ConditionalSignalAssignment.ConditionalWaveformElement element = new ConditionalSignalAssignment.ConditionalWaveformElement($w.value); }
                ( expression { element.Condition = $expression.value; } )?
                { $value.Add(element); }
            )*
        )
    ;

configuration_declaration[List<LibraryUnit> contextItems] returns [Configuration value]
@init {
    List<IConfigurationDeclarativeItem> declarations =
        new List<IConfigurationDeclarativeItem>();
}
@after { AddAnnotations($value, $start); }
    :   ^( CONFIGURATION identifier entity=name
            ( cdi=configuration_declarative_item { declarations.Add($cdi.value); } )*
            { AddListEndComments($cdi.value, $cdi.start); }
            bc=block_configuration
            {
                $value = new Configuration($identifier.text, $entity.value.toEntity(currentScope), $bc.value);
                $value.ContextItems.AddRange(contextItems);
            	contextItems.Clear();
                AddRange($value.Declarations, declarations);
            }
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($value.Identifier, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_CONFIGURATION, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $value.Identifier));
            }
        )
    ;

configuration_declarative_item returns [IConfigurationDeclarativeItem value]
    :   use_clause              { $value = $use_clause.value; }
    |   attribute_specification { $value = $attribute_specification.value; }
    |   group_declaration       { $value = $group_declaration.value; }
    ;

configuration_item returns [ConfigurationItem value]
    :   block_configuration     { $value = $block_configuration.value; }
    |   component_configuration { $value = $component_configuration.value; }
    ;

configuration_specification returns [ConfigurationSpecification value]
@after { AddAnnotations($value, $start); }
    :   ^( CONFIGURATION_SPECIFICATION 
            cs=component_specification { $value = new ConfigurationSpecification($cs.value); }
            ( ea=entity_aspect { $value.EntityAspect = $ea.value; } )?
            ( gma=generic_map_aspect { AddRange($value.GenericMap, $gma.value); } )?
            ( pma=port_map_aspect { AddRange($value.PortMap, $pma.value); } )?
        )
    ;

constant_declaration returns [ConstantDeclaration value]
@after 
{
	AddAnnotations($value, $start);
	$value.Parent = currentScope;
}
    :   ^( CONSTANT identifier_list si=subtype_indication def=expression? )
        {
            List<Constant> constants = new List<Constant>();
            foreach (string identifier in $identifier_list.value) 
            {
                constants.Add(new Constant(identifier, $si.value, $def.value));
            }
            $value = new ConstantDeclaration(constants);
        }
    ;

constrained_array_definition[string ident] returns [ConstrainedArray value]
@after { AddAnnotations($value, $start); }
    :   ^( CONSTRAINED_ARRAY_DEFINITION ic=index_constraint elementType=subtype_indication )
        { $value = new ConstrainedArray($ident, $elementType.value, $ic.value); }
    ;

context_item returns [LibraryUnit value]
    :   library_clause { $value = $library_clause.value; }
    |   use_clause     { $value = $use_clause.value; }
    ;

delay_mechanism returns [DelayMechanism value]
@init {
    $value = DelayMechanism.INERTIAL;
}
    :   TRANSPORT { $value = DelayMechanism.TRANSPORT; }
    |   ^( INERTIAL { $value = DelayMechanism.INERTIAL; }
            ( time=expression { $value = DelayMechanism.REJECT_INERTIAL($time.value); } )?
        )
    ;

public
design_file returns [VhdlFile value]
@init {
    $value = new VhdlFile();
    List<LibraryUnit> contextItems = new List<LibraryUnit>();
    libraryScope.Files.Add($value);
    currentScope = $value;
}
    :   (
    	    (
	            ( 
	                context_item
	                {
	                    if ($context_item.value is LibraryClause) {
	                        LibraryClause lc = (LibraryClause)$context_item.value;
	                        foreach (string library in lc.getLibraries())
	                        {
	                        	LibraryDeclarativeRegion loaded_library = LoadLibrary(library);
	                        	if(loaded_library != null)
		                        	rootScope.AddLibrary(loaded_library);
	                        }
	                    }
	                    contextItems.Add($context_item.value);
	                }
	            )*
	            (
		            primary_unit[contextItems]
		            { 
		            	$value.Elements.Add($primary_unit.value);
		            }
				|
		            secondary_unit[contextItems]
		            { 
		            	$value.Elements.Add($secondary_unit.value);
		            }
	            )        
            	    
            )
        )* EOF
    ;

designator
    :   identifier
    |   STRING_LITERAL
    ;

direction returns [Range.RangeDirection value]
    :   TO     { $value = Range.RangeDirection.TO; }
    |   DOWNTO { $value = Range.RangeDirection.DOWNTO; }
    ;

disconnection_specification returns [DisconnectionSpecification value]
@after { AddAnnotations($value, $start); }
    :   ^( DISCONNECT sl=signal_list type_mark=name after=expression )
        { $value = new DisconnectionSpecification($sl.value, $type_mark.value.toTypeMark(currentScope), $after.value); }
    ;

discrete_range returns [DiscreteRange value]
    :   ^( direction left=expression right=expression)
        { $value = new Range($left.value, $direction.value, $right.value); }
    |   ^( DISCRETE_RANGE
            type_mark_or_range_attribute=name
            (
                    range_constraint
                    {
                        $value = $type_mark_or_range_attribute.value.toDiscreteRange(
                            currentScope, $range_constraint.value);
                    }
                |   index_constraint
                    {
                        $value = $type_mark_or_range_attribute.value.toDiscreteRange(
                            currentScope, $index_constraint.value);
                    }
                |
                    { $value = $type_mark_or_range_attribute.value.toDiscreteRange(currentScope); }
            )
        )
    ;

//TODO: don't use dummy objects
entity_aspect returns [EntityAspect value]
    :   ^( ENTITY entity=name architecture=identifier? )
        {
            Entity dummyEntity = new Entity($entity.text);
            if ($architecture.text != null)
            {
                //TODO: remove dummy architecture
                Architecture dummy = new Architecture($architecture.text, dummyEntity);
                $value = EntityAspect.architecture(dummy);
            }
            else
            {
                $value = EntityAspect.entity(dummyEntity);
            }
        }
    |   ^( CONFIGURATION configuration=name )
        {
            Configuration dummy = new Configuration($configuration.text, null, null);
            $value = EntityAspect.configuration(dummy);
        }
    |   OPEN
        { $value = EntityAspect.OPEN; }
    ;

entity_class returns [EntityClass value]
    :   ENTITY        { $value = EntityClass.ENTITY; }
    |   ARCHITECTURE  { $value = EntityClass.ARCHITECTURE; }
    |   CONFIGURATION { $value = EntityClass.CONFIGURATION; }
    |   PROCEDURE     { $value = EntityClass.PROCEDURE; }
    |   FUNCTION      { $value = EntityClass.FUNCTION; }
    |   PACKAGE       { $value = EntityClass.PACKAGE; }
    |   TYPE          { $value = EntityClass.TYPE; }
    |   SUBTYPE       { $value = EntityClass.SUBTYPE; }
    |   CONSTANT      { $value = EntityClass.CONSTANT; }
    |   SIGNAL        { $value = EntityClass.SIGNAL; }
    |   VARIABLE      { $value = EntityClass.VARIABLE; }
    |   COMPONENT     { $value = EntityClass.COMPONENT; }
    |   LABEL         { $value = EntityClass.LABEL; }
    |   LITERAL       { $value = EntityClass.LITERAL; }
    |   UNITS         { $value = EntityClass.UNITS; }
    |   GROUP         { $value = EntityClass.GROUP; }
    |   FILE          { $value = EntityClass.FILE; }
    ;

entity_declaration[List<LibraryUnit> contextItems] returns [Entity value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after 
{
    currentScope = oldScope;
    AddAnnotations($value, $start);
}
    :   ^( ENTITY
            identifier
            {
                $value = new Entity($identifier.text);
                $value.Parent = oldScope;
                currentScope = $value;
                $value.ContextItems.AddRange(contextItems);
            	contextItems.Clear();
            }
            ( gc=generic_clause { AddRange($value.Generic, $gc.value); } )?
            ( pc=port_clause { AddRange($value.Port, $pc.value); } )?
            ( edi=entity_declarative_item { $value.Declarations.Add($edi.value); } )*
            { AddListEndComments($edi.value, $edi.start); }
            ( es=entity_statement { $value.Statements.Add($es.value); } )*
            { AddListEndComments($es.value, $es.start); }
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($value.Identifier, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_ENTITY, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $value.Identifier));
            }
        )
    ;

entity_declarative_item returns [IEntityDeclarativeItem value]
    :   subprogram_declaration      { $value = $subprogram_declaration.value; }
    |   subprogram_body             { $value = $subprogram_body.value; }
    |   type_declaration            { $value = $type_declaration.value; }
    |   subtype_declaration         { $value = $subtype_declaration.value; }
    |   variable_declaration        { $value = $variable_declaration.value; }
    |   constant_declaration        { $value = $constant_declaration.value; }
    |   signal_declaration          { $value = $signal_declaration.value; }
    |   file_declaration            { $value = $file_declaration.value; }
    |   alias_declaration           { $value = $alias_declaration.value; }
    |   attribute_specification     { $value = $attribute_specification.value; }
    |   attribute_declaration       { $value = $attribute_declaration.value; }
    |   disconnection_specification { $value = $disconnection_specification.value; }
    |   use_clause                  { $value = $use_clause.value; }
    |   group_template_declaration  { $value = $group_template_declaration.value; }
    |   group_declaration           { $value = $group_declaration.value; }
    ;

//TODO: don't use entity_tag.text?
entity_designator returns [VHDL.declaration.AttributeSpecification.EntityNameList.EntityDesignator value]
    :   entity_tag signature?
        { $value = new VHDL.declaration.AttributeSpecification.EntityNameList.EntityDesignator($entity_tag.text, $signature.value); }
    ;

entity_name_list returns [VHDL.declaration.AttributeSpecification.EntityNameList value]
    :   { $value = new VHDL.declaration.AttributeSpecification.EntityNameList(); }
        (
            entity_designator { $value.Designators.Add($entity_designator.value); }
        )*
    |   OTHERS { $value = VHDL.declaration.AttributeSpecification.EntityNameList.OTHERS; }
    |   ALL { $value = VHDL.declaration.AttributeSpecification.EntityNameList.ALL; }
    ;

entity_statement returns [EntityStatement value]
@init { bool isPostponed = false; }
@after { AddAnnotations($value, $start); }
    :   ^( ENTITY_STATEMENT identifier? ( POSTPONED { isPostponed = true; } )?
            (
                    cas=concurrent_assertion_statement[$identifier.text]
                    { $value = $cas.value; }
                |   ps=process_statement[$identifier.text, isPostponed]
                    { $value = $ps.value; }
                |   cpcs=concurrent_procedure_call_statement[$identifier.text]
                    { $value = $cpcs.value; }
            )
            {
                if ($value != null) {
                    $value.Postponed = isPostponed;
                }
            }
        )
    ;

entity_tag
    :   identifier
    |   CHARACTER_LITERAL
    |   STRING_LITERAL
    ;

enumeration_type_definition[String ident] returns [EnumerationType value]
@init { $value = new EnumerationType($ident); }
    :   ^( ENUMERATION_TYPE_DEFINITION
            (
                    identifier           { $value.createLiteral($identifier.text); }
                |   cl=CHARACTER_LITERAL { $value.createLiteral($cl.text); }
            )+
        )
    ;

exit_statement[string label] returns [ExitStatement value = new ExitStatement()]
@after { AddAnnotations($value, $start); }
    :   ^( EXIT
            { $value.Label = $label; }
            ( loop_label { $value.Loop = $loop_label.value; } )?
            ( expression { $value.Condition = $expression.value; } )?
        )
    ;

expression returns [Expression value]
@after 
{
	AddAnnotations($value, $start);
}
    :   ^( EXPRESSION expression2 ) { $value = $expression2.value; }
    ;

expression2 returns [Expression value]
    :   ^( lo=logical_operator l=expression2 r=expression2 )
        { $value = ExpressionTypeCreator.create($lo.value, $l.value, $r.value); }
    |   relation
        { $value = $relation.value; }
    ;

factor returns [Expression value]
    :   ^( DOUBLESTAR l=primary r=primary ) { $value = new Pow($l.value, $r.value); }
    |   ^( ABS primary )                    { $value = new Abs($primary.value); }
    |   ^( NOT primary )                    { $value = new Not($primary.value); }
    |   primary                             { $value = $primary.value; }
    ;

file_declaration returns [FileDeclaration value]
@after { AddAnnotations($value, $start); }
    :   ^( FILE identifier_list si=subtype_indication
            ( ^( OPEN open_kind=expression) )? logical_name=expression?
            {
                List<FileObject> files = new List<FileObject>();
                foreach (string ident in $identifier_list.value)
                {
                    files.Add(new FileObject(ident, $si.value, $open_kind.value,
                        $logical_name.value));
                }
                $value = new FileDeclaration(files);
            }
        )
    ;

file_type_definition[string ident] returns [FileType value]
@after { AddAnnotations($value, $start); }
    :   ^( FILE_TYPE_DEFINITION type_mark=name )
        { $value = new FileType($ident, $type_mark.value.toTypeMark(currentScope)); }
    ;

//annotations handled in concurrent_statement
generate_statement[string label] returns [AbstractGenerateStatement value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
}
    :   ^( GENERATE
            generation_scheme[label]
            {
                $value = $generation_scheme.value;
                $value.Parent = oldScope;
                currentScope = $value;
            }
            ( bdi=block_declarative_item { $value.Declarations.Add($bdi.value); } )*
            { AddListEndComments($bdi.value, $bdi.start); }
            ( cs=concurrent_statement { $value.Statements.Add($cs.value); } )*
            { AddListEndComments($cs.value, $cs.start); }
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($label, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_GENERATE_STATEMENT, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $label));
            }
        )
    ;

generation_scheme[string label] returns [AbstractGenerateStatement value]
    :   FOR identifier discrete_range
        { $value = new ForGenerateStatement($label, $identifier.text, $discrete_range.value); }
    |   IF expression
        { $value = new IfGenerateStatement($label, $expression.value); }
    ;

generic_clause returns [List<IVhdlObjectProvider> value]
@init { $value = new List<IVhdlObjectProvider>(); }
    :   ^( GENERIC
            ( icd=interface_constant_declaration { $value.Add($icd.value); } )+
            { AddListEndComments($icd.value, $icd.start); }
        )
    ;

generic_map_aspect returns [List<AssociationElement> value]
    :   ^( GENERIC_MAP association_list ) { $value = $association_list.value; }
    ;

group_constituent
    :   name
    |   CHARACTER_LITERAL
    ;

//TODO: remove dummy GroupTemplate
//TODO: handle group_constituent correctly
//TODO: fix name ambiguity (see VhdlAntlr.g)
group_declaration returns [Group value]
@after { AddAnnotations($value, $start); }
    :   ^( GROUP_DECLARATION
            identifier group_template=name
            {
                GroupTemplate dummy = new GroupTemplate($group_template.text);
                $value = new Group($identifier.text, dummy);
            }
            ( gc=group_constituent { $value.Constituents.Add($gc.text); } )+
        )
    ;

group_template_declaration returns [GroupTemplate value]
@after { AddAnnotations($value, $start); }
    :   ^( GROUP_TEMPLATE_DECLARATION
            identifier { $value = new GroupTemplate($identifier.text); }
            (
                ec=entity_class { $value.EntityClasses.Add($ec.value); }
                ( BOX { $value.RepeatLast = true; } )?
            )+
        )
    ;

identifier
    :   BASIC_IDENTIFIER
    |   EXTENDED_IDENTIFIER
    ;

identifier_list returns [List<string> value = new List<string>()]
    :   ( identifier { $value.Add($identifier.text); } )+
    ;
end_identifier
 	:	identifier;

if_statement[string label] returns [IfStatement value]
@after { AddAnnotations($value, $start); }
    :   ^( IF
            c1=expression
            {
                $value = new IfStatement($c1.value);
                $value.Label = $label;
            }
            ( ss1=sequential_statement { $value.Statements.Add($ss1.value); } )*
            { AddListEndComments($ss1.value, $ss1.start); }
            (
                ^( ELSIF
                    c2=expression
                    { IfStatement.ElsifPart part = $value.createElsifPart($c2.value); }
                    ( ss2=sequential_statement { part.Statements.Add($ss2.value); } )*
                    { AddListEndComments($ss2.value, $ss2.start); }
                )
            )*
            (
                ^( ELSE
                    ( ss3=sequential_statement { $value.ElseStatements.Add($ss3.value); } )*
                    { AddListEndComments($ss3.value, $ss3.start); }
                )
            )?
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($label, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_IF, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $label));
            }
        )
    ;

index_constraint returns [List<DiscreteRange> value = new List<DiscreteRange>()]
    :   ^( INDEX_CONSTRAINT ( discrete_range { $value.Add($discrete_range.value); } )+ )
    ;

instantiated_unit[string label] returns [AbstractComponentInstantiation value]
@init { bool optionalComponent = false; }
    :   ^( COMPONENT_INSTANCE
            ( COMPONENT { optionalComponent = true; } )?
            component=name
        )
        {
            $value = new ComponentInstantiation($label, $component.value.toComponent(currentScope));
            if (optionalComponent) {
                Annotations.putAnnotation(
                    $value, 
                    new ComponentInstantiationFormat(optionalComponent)
                );
            }
        }
    |   ^( ENTITY entity=name
            (
                    architecture=identifier
                    {
                        //TODO: remove dummy architecture
                        Architecture arch = new Architecture($architecture.text, $entity.value.toEntity(currentScope));
                        $value = new ArchitectureInstantiation($label, arch);
                    }
                |
                    { $value = new EntityInstantiation($label, $entity.value.toEntity(currentScope)); }
            )
        )
    |   ^( CONFIGURATION configuration=name )
        { $value = new ConfigurationInstantiation($label, $configuration.value.toConfiguration(currentScope)); }
    ;

//TODO: float range necessary?
integer_or_float_type_definition[string ident] returns [IntegerType value]
@after { AddAnnotations($value, $start); }
    :   ^( INTEGER_OR_FLOAT_TYPE_DEFINITION range_constraint )
        { $value = new IntegerType($ident, $range_constraint.value); }
    ;

interface_constant_declaration returns [ConstantGroup value]
@init{
    bool hasObjectClass = false;
    bool hasMode = false;
}
@after {
    AddAnnotations($value, $start);
}
    :   ^( INTERFACE_CONSTANT_DECLARATION
            ( CONSTANT { hasObjectClass = true; } )?
            identifier_list
            ( IN { hasMode = true;} )?
            si=subtype_indication
            def=expression?
        )
        {
            InterfaceDeclarationFormat format =
                new InterfaceDeclarationFormat(hasObjectClass, hasMode);

            $value = new ConstantGroup();
            foreach (string identifier in $identifier_list.value)
            {
                Constant c = new Constant(identifier, $si.value, $def.value);
                Annotations.putAnnotation(c, format);

                $value.Elements.Add(c);
            }
        }
    ;

interface_declaration returns [IVhdlObjectProvider value]
    :   isd=interface_signal_declaration   { $value = $isd.value; }
    |   icd=interface_constant_declaration { $value = $icd.value; }
    |   ivd=interface_variable_declaration { $value = $ivd.value; }
    |   ifd=interface_file_declaration     { $value = $ifd.value; }
    ;

interface_file_declaration returns [FileGroup value]
    :   ^( INTERFACE_FILE_DECLARATION FILE identifier_list subtype_indication )
        {
            $value = new FileGroup();
            foreach (string identifier in $identifier_list.value)
            {
                $value.Elements.Add(new FileObject(identifier, $subtype_indication.value));
            }
        }
    ;

interface_signal_declaration returns [SignalGroup value]
@init{
    bool hasObjectClass = false;
    bool hasMode = false;
    bool isBus = false;
}
@after {
    AddAnnotations($value, $start);
}
    :   ^( INTERFACE_SIGNAL_DECLARATION
            ( SIGNAL { hasObjectClass = true; } )?
            identifier_list
            ( mode { hasMode = true; } )?
            si=subtype_indication
            ( BUS { isBus = true; } )?
            def=expression?
        )
        {
            InterfaceDeclarationFormat format =
                new InterfaceDeclarationFormat(hasObjectClass, hasMode);

            $value = new SignalGroup();
            Signal.ModeEnum m = (($mode.value == null) ? Signal.ModeEnum.IN : $mode.value);
            foreach (string identifier in $identifier_list.value) {
                Signal s = new Signal(identifier, m, $si.value, $def.value);
                if (isBus) 
                {
                    s.Kind = Signal.KindEnum.BUS;
                }
                Annotations.putAnnotation(s, format);

                $value.Elements.Add(s);
            }
        }
    ;

interface_variable_declaration returns [VariableGroup value]
@init{
    bool hasObjectClass = false;
    bool hasMode = false;
}
    :   ^( INTERFACE_VARIABLE_DECLARATION
            ( VARIABLE { hasObjectClass = true; } )?
            identifier_list
            ( mode { hasMode = true; } )?
            si=subtype_indication
            def=expression?
        )
        {
            InterfaceDeclarationFormat format =
                new InterfaceDeclarationFormat(hasObjectClass, hasMode);

            $value = new VariableGroup();
            foreach (string identifier in $identifier_list.value)
            {
                Variable v = new Variable(identifier, $si.value, $def.value);
                if (hasMode)
                {
                    v.Mode = $mode.value;
                }
                Annotations.putAnnotation(v, format);

                $value.Elements.Add(v);
            }
        }
    ;

iteration_scheme returns [LoopStatement value]
    :   ^( WHILE expression )
        { $value = new WhileStatement($expression.value); }
    |   ^( FOR identifier discrete_range )
        { $value = new ForStatement($identifier.text, $discrete_range.value); }
    |   UNCONDITIONAL_LOOP
        { $value = new LoopStatement(); }
    ;

library_clause returns [LibraryClause value]
@after
{
	AddAnnotations($value, $start);
	CheckLibraryClause($library_clause.start, $value);
}
    :   ^( LIBRARY logical_name_list )
        { $value = new LibraryClause($logical_name_list.value); }
    ;

primary_unit[List<LibraryUnit> contextItems] returns [PrimaryUnit value]
    :   entity_declaration       [contextItems] { $value = $entity_declaration.value; }
    |   configuration_declaration[contextItems] { $value = $configuration_declaration.value; }
    |   package_declaration      [contextItems] { $value = $package_declaration.value; }
    ;
    
secondary_unit[List<LibraryUnit> contextItems] returns [SecondaryUnit value]
    :	architecture_body        [contextItems] { $value = $architecture_body.value; }
    |   package_body             [contextItems] { $value = $package_body.value; }
    ;

logical_name_list returns [List<string> value = new List<string>()]
    :   ( identifier { $value.Add($identifier.text); } )+
    ;

logical_operator returns [ExpressionType value]
    :   AND  { $value = ExpressionType.AND; }
    |   OR   { $value = ExpressionType.OR; }
    |   NAND { $value = ExpressionType.NAND; }
    |   NOR  { $value = ExpressionType.NOR; }
    |   XOR  { $value = ExpressionType.XOR; }
    |   XNOR { $value = ExpressionType.XNOR; }
    ;

loop_statement[string label] returns [LoopStatement value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
    AddAnnotations($value, $start);
}
    :   ^( LOOP iteration_scheme
            {
                $value = $iteration_scheme.value;
                $value.Label = $label;
                $value.Parent = oldScope;
                currentScope = $value;
            }
            ( ss=sequential_statement { $value.Statements.Add($ss.value); } )*
            { AddListEndComments($ss.value, $ss.start); }
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($label, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_LOOP, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $label));
            }
        )
    ;

mode returns [VhdlObject.ModeEnum value]
    :   IN      { $value = VhdlObject.ModeEnum.IN; }
    |   OUT     { $value = VhdlObject.ModeEnum.OUT; }
    |   INOUT   { $value = VhdlObject.ModeEnum.INOUT; }
    |   BUFFER  { $value = VhdlObject.ModeEnum.BUFFER; }
    |   LINKAGE { $value = VhdlObject.ModeEnum.LINKAGE; }
    ;

multiplying_operator returns [ExpressionType value]
    :   MUL { $value = ExpressionType.MUL; }
    |   DIV { $value = ExpressionType.DIV; }
    |   MOD { $value = ExpressionType.MOD; }
    |   REM { $value = ExpressionType.REM; }
    ;

// was
//   name
//     : simple_name
//     | operator_symbol
//     | selected_name
//     | indexed_name
//     | slice_name
//     | attribute_name
//     ;
name returns [TemporaryName value]
    :   ^( NAME
            (       identifier
                    { $value = new TemporaryName(this, $name.start, $identifier.text); }
                |   STRING_LITERAL
                    {
                        string literal = $STRING_LITERAL.text;
                        literal = literal.Substring(1, literal.Length - 1);
                        $value = new TemporaryName(this, $name.start, new StringLiteral(literal));
                    }
            )
            (
                    name_indexed_part   { $value.AddPart($name_indexed_part.value); }
                |   name_slice_part     { $value.AddPart($name_slice_part.value); }
                |   name_attribute_part { $value.AddPart($name_attribute_part.value); }
                |   name_selected_part  { $value.AddPart($name_selected_part.value); }
                |   association_list
                    {
                        Part part =
                            Part.CreateAssociation($association_list.value);
                        $value.AddPart(part);
                    }
                |   name_indexed_or_slice_part
                    { $value.AddPart($name_indexed_or_slice_part.value); }
            )*
        )
    ;

name_attribute_part returns [Part value]
    :   ^( NAME_ATTRIBUTE_PART signature? identifier expression? )
        {
            $value = Part.CreateAttribute($identifier.text, $expression.value,
                $signature.value);
        }
    ;

name_indexed_part returns [Part value]
@init { List<Expression> indices = new List<Expression>(); }
    :   ^( NAME_INDEXED_PART
            ( expression { indices.Add($expression.value); } )+
        )
        { $value = Part.CreateIndexed(indices); }
    ;

//TODO: don't use suffix.text
name_selected_part returns [Part value]
    :   ^( NAME_SELECTED_PART suffix )
        { $value = Part.CreateSelected($suffix.text); }
    ;

name_slice_part returns [Part value]
    :   ^( NAME_SLICE_PART discrete_range )
        { $value = Part.CreateSlice($discrete_range.value); }
    ;

name_indexed_or_slice_part returns [Part value]
    :   ^( NAME_INDEXED_OR_SLICE_PART name )
        { $value = TemporaryName.CreateIndexedOrSlicePart($name.value, currentScope); }
    ;

next_statement[string label] returns [NextStatement value = new NextStatement()]
    :   ^( NEXT
            { $value.Label = $label; }
            ( loop_label { $value.Loop = $loop_label.value; } )?
            ( expression { $value.Condition = $expression.value; } )?
        )
    ;

null_statement[string label] returns [NullStatement value = new NullStatement()]
@after { AddAnnotations($value, $start); }
    :   NULLTOK
        { $value.Label = $label; }
    ;

package_body [List<LibraryUnit> contextItems] returns [PackageBody value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
    AddAnnotations($value, $start);
}
    :   ^( PACKAGE_BODY
            psn=package_simple_name
            {
                $value = new PackageBody($psn.value);
                $value.Parent = oldScope;
                currentScope = $value;
                $value.ContextItems.AddRange(contextItems);
            	contextItems.Clear();
            }
            ( pbdi=package_body_declarative_item { $value.Declarations.Add($pbdi.value); } )*
            { AddListEndComments($pbdi.value, $pbdi.start); }
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($value.Package.Identifier, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_PACKAGE, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $value.Package.Identifier));
            }
        )
    ;

package_body_declarative_item returns [IPackageBodyDeclarativeItem value]
    :   subprogram_declaration     { $value = $subprogram_declaration.value; }
    |   subprogram_body            { $value = $subprogram_body.value; }
    |   type_declaration           { $value = $type_declaration.value; }
    |   subtype_declaration        { $value = $subtype_declaration.value; }
    |   constant_declaration       { $value = $constant_declaration.value; }
    |   variable_declaration       { $value = $variable_declaration.value; }
    |   file_declaration           { $value = $file_declaration.value; }
    |   alias_declaration          { $value = $alias_declaration.value; }
    |   use_clause                 { $value = $use_clause.value; }
    |   group_template_declaration { $value = $group_template_declaration.value; }
    |   group_declaration          { $value = $group_declaration.value; }
    ;
    
package_declaration[List<LibraryUnit> contextItems] returns [PackageDeclaration value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
    AddAnnotations($value, $start);
}
    :   ^( PACKAGE
            identifier
            {
                $value = new PackageDeclaration($identifier.text);
                $value.ContextItems.AddRange(contextItems);
            	contextItems.Clear();
                $value.Parent = oldScope;
                currentScope = $value;
            }
            ( pdi=package_declarative_item { $value.Declarations.Add($pdi.value); } )*
            { AddListEndComments($pdi.value, $pdi.start); }
	    end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($identifier.text, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_PACKAGE, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $identifier.text));
            }
        )
    ;

package_declarative_item returns [IPackageDeclarativeItem value]
    :   subprogram_declaration      { $value = $subprogram_declaration.value; }
    |   type_declaration            { $value = $type_declaration.value; }
    |   subtype_declaration         { $value = $subtype_declaration.value; }
    |   constant_declaration        { $value = $constant_declaration.value; }
    |   signal_declaration          { $value = $signal_declaration.value; }
    |   variable_declaration        { $value = $variable_declaration.value; }
    |   file_declaration            { $value = $file_declaration.value; }
    |   alias_declaration           { $value = $alias_declaration.value; }
    |   component_declaration       { $value = $component_declaration.value; }
    |   attribute_specification     { $value = $attribute_specification.value; }
    |   attribute_declaration       { $value = $attribute_declaration.value; }
    |   disconnection_specification { $value = $disconnection_specification.value; }
    |   use_clause                  { $value = $use_clause.value; }
    |   group_template_declaration  { $value = $group_template_declaration.value; }
    |   group_declaration           { $value = $group_declaration.value; }
    ;

//TODO: don't use name.text
physical_type_definition[string ident] returns [PhysicalType value]
@after { AddAnnotations($value, $start); }
    :   ^( PHYSICAL_TYPE_DEFINITION
            range_constraint baseUnit=identifier
            { $value = new PhysicalType($ident, $range_constraint.value, $baseUnit.text); }
            (
                unit=identifier
                (
                        al=abstract_literal n1=name
                        { $value.createUnit($unit.text, $al.value, $n1.text); }
                    |   n2=name
                        { $value.createUnit($unit.text); }
                )
            )*
            end_identifier?
            {
            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($value.Identifier, StringComparison.InvariantCultureIgnoreCase)))
            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_TYPE, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $value.Identifier));
            }
        )
    ;

port_clause returns [List<IVhdlObjectProvider> value]
@init { $value = new List<IVhdlObjectProvider>(); }
    :   ^( PORT
            ( isd=interface_signal_declaration { $value.Add($isd.value); } )+
            { AddListEndComments($isd.value, $isd.start); }
        )
    ;

port_map_aspect returns [List<AssociationElement> value]
    :   ^( PORT_MAP association_list )
        { $value = $association_list.value; }
    ;
    
primary returns [Expression value]
@after { AddAnnotations($value, $start); }
    :   abstract_literal { $value = $abstract_literal.value; }
    |	^(PHYSICAL_LITERAL abstract_literal identifier)
        { $value = new PhysicalLiteral($abstract_literal.value, $identifier.text); }
    |   FLOAT_POINT_LITERAL	{ $value = new RealLiteral($FLOAT_POINT_LITERAL.text); }
    |   CHARACTER_LITERAL
        { $value = new CharacterLiteral($CHARACTER_LITERAL.text[1]); }
    |   BIT_STRING_LITERAL_BINARY
        {
            String v = $BIT_STRING_LITERAL_BINARY.text;
            v = v.Substring(2, v.Length - 1 - 2);
            $value = new BinaryStringLiteral(v);
        }
    |   BIT_STRING_LITERAL_OCTAL
        {
            String v = $BIT_STRING_LITERAL_OCTAL.text;
            v = v.Substring(2, v.Length - 1 - 2);
            $value = new OctalStringLiteral(v);
        }
    |   BIT_STRING_LITERAL_HEX
        {
            String v = $BIT_STRING_LITERAL_HEX.text;
            v = v.Substring(2, v.Length - 1 - 2);
            $value = new HexStringLiteral(v);
        }
    |   NULLTOK
        { $value = Literals.NULL; }
    |   aggregate
        {
            Aggregate a = $aggregate.value;
            if (a.Associations.Count == 1 &&
                    a.Associations[0].Choices.Count == 0) {
                $value = new Parentheses(a.Associations[0].Expression);
            } else {
                $value = a;
            }
        }
    |   allocator
        { $value = $allocator.value; }
    |   name
        { $value = $name.value.toPrimary(currentScope, inElementAssociation); }
    |   qualified_expression
        { $value = $qualified_expression.value; }
    ;

procedure_call_statement[string label] returns [ProcedureCall value]
@after { AddAnnotations($value, $start); }
   :   ^( PROCEDURE_CALL 
            procedure=name 
            {
                $value = new ProcedureCall($procedure.value.toProcedure(currentScope));
                $value.Label = $label;
            }
            ( 
                parameters=association_list { AddRange($value.Parameters, $parameters.value);}
            )?
        )
    ;

process_declarative_item returns [IProcessDeclarativeItem value]
    :   subprogram_declaration     { $value = $subprogram_declaration.value; }
    |   subprogram_body            { $value = $subprogram_body.value; }
    |   type_declaration           { $value = $type_declaration.value; }
    |   subtype_declaration        { $value = $subtype_declaration.value; }
    |   constant_declaration       { $value = $constant_declaration.value; }
    |   variable_declaration       { $value = $variable_declaration.value; }
    |   file_declaration           { $value = $file_declaration.value; }
    |   alias_declaration          { $value = $alias_declaration.value; }
    |   attribute_specification    { $value = $attribute_specification.value; }
    |   attribute_declaration      { $value = $attribute_declaration.value; }
    |   use_clause                 { $value = $use_clause.value; }
    |   group_template_declaration { $value = $group_template_declaration.value; }
    |   group_declaration          { $value = $group_declaration.value; }
    ;

//annotations handled in concurrent_statement & entity_statement
process_statement[string label, bool isPostponed] returns [ProcessStatement value]
@init {
    $value = new ProcessStatement($label);

    IDeclarativeRegion oldScope = currentScope;
    $value.Parent = oldScope;
    currentScope = $value;
}
@after {
    currentScope = oldScope;
    CheckProcess($process_statement.start, $value);
}
    :   ^( PROCESS
            ( sl=sensitivity_list { AddRange($value.SensitivityList, $sl.value); } )?
            (
                IS
                {
                    Annotations.putAnnotation($value, 
                        new OptionalIsFormat(true));
                }
            )?
            ( pdi=process_declarative_item { $value.Declarations.Add($pdi.value); } )*
            { AddListEndComments($pdi.value, $pdi.start); }
            ( ss=sequential_statement { $value.Statements.Add($ss.value); } )*
            { AddListEndComments($ss.value, $ss.start); }
            (
	            end_identifier
	            {
	            	if(($end_identifier.text != null) && (!$end_identifier.text.Equals($label, StringComparison.InvariantCultureIgnoreCase)))
	            		resolveError($end_identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_PROCESS, string.Format("Mismatched identifier {0}, suggested {1} ", $end_identifier.text, $label));
	            }
            )?
            (
	            POSTPONED
	            {
	            	if($isPostponed == false)
	            		resolveError($POSTPONED, ParseError.ParseErrorTypeEnum.UNKNOWN_PROCESS, string.Format("Current process is not posponed "));
	            }
            )?
        )
    ;

//: ^( QUALIFIED_EXPRESSION type_mark ( aggregate | expression ) )
qualified_expression returns [QualifiedExpression value]
@after { AddAnnotations($value, $start); }
    :   ^( QUALIFIED_EXPRESSION type_mark=name aggregate )
        {
            $value = new QualifiedExpression($type_mark.value.toTypeMark(currentScope), $aggregate.value);
        }
    ;

range returns [RangeProvider value]
    :   ^( direction left=expression right=expression)
        { $value = new Range($left.value, $direction.value, $right.value); }
    |   name
        { $value = $name.value.toRangeName(currentScope); }
    ;

range_constraint returns [RangeProvider value]
    :   ^( RANGETOK range )
        { $value = $range.value; }
    ;

record_type_definition[string ident] returns [RecordType value]
@init { $value = new RecordType($ident); }
@after { AddAnnotations($value, $start); }
    :   ^( RECORD_TYPE_DEFINITION
            ( 
                identifier_list subtype_indication
                { $value.createElement($subtype_indication.value, $identifier_list.value); }
            )+
        )
    ;

relation returns [Expression value]
    :   ^( relational_operator l=relation r=relation )
        { $value = ExpressionTypeCreator.create($relational_operator.value, $l.value, $r.value); }
    |   shift_expression
        { $value = $shift_expression.value; }
    ;

relational_operator returns [ExpressionType value]
    :   EQ  { $value = ExpressionType.EQ; }
    |   NEQ { $value = ExpressionType.NEQ; }
    |   LT  { $value = ExpressionType.LT; }
    |   LE  { $value = ExpressionType.LE; }
    |   GT  { $value = ExpressionType.GT; }
    |   GE  { $value = ExpressionType.GE; }
    ;

report_statement[string label] returns [ReportStatement value]
@after { AddAnnotations($value, $start); }
    :   ^( REPORT
            condition=expression
            {
                $value = new ReportStatement($condition.value);
                $value.Label = $label;
            }
            ( severity=expression { $value.Severity = $severity.value; } )?
        )
    ;

return_statement[string label] returns [ReturnStatement value = new ReturnStatement()]
@after { AddAnnotations($value, $start); }
    :   ^( RETURN
            { $value.Label = $label; }
            ( expression { $value.ReturnedExpression = $expression.value; } )?
        )
    ;

//annotations handled in concurrent_statement
selected_signal_assignment returns [SelectedSignalAssignment value]
@init { bool isGuarded; }
    :   expression target_signal
        { $value = new SelectedSignalAssignment($expression.value, $target_signal.value); }
        ( GUARDED { $value.Guarded = true; } )?
        ( delay_mechanism { $value.DelayMechanism = $delay_mechanism.value; } )?
        selected_waveforms { AddRange($value.SelectedWaveforms, $selected_waveforms.value); }
    ;

selected_waveforms returns [List<SelectedSignalAssignment.SelectedWaveform> value]
@init { $value = new List<SelectedSignalAssignment.SelectedWaveform>(); }
    :   (
            waveform choices
            {
                $value.Add(new SelectedSignalAssignment.SelectedWaveform($waveform.value, $choices.value));
            }
        )+
    ;

sensitivity_list returns [List<Signal> value = new List<Signal>()]
    :   ( signal=name { $value.Add($signal.value.toSignal(currentScope)); } )+
    ;

sequential_statement returns [SequentialStatement value]
@after 
{ 
	AddAnnotations($value, $start);
	$value.Parent = currentScope;
}
    :   ^( LABEL_STATEMENT identifier sequential_statement2[$identifier.text] )
        { $value = $sequential_statement2.value; }
    |   sequential_statement2[null]
        { $value = $sequential_statement2.value; }
    ;

sequential_statement2[string label] returns [SequentialStatement value]
    : s00=wait_statement[$label]                { $value = $s00.value; }
    | s01=assertion_statement[$label]           { $value = $s01.value; }
    | s02=report_statement[$label]              { $value = $s02.value; }
    | s03=signal_assignment_statement[$label]   { $value = $s03.value; }
    | s04=variable_assignment_statement[$label] { $value = $s04.value; }
    | s05=if_statement[$label]                  { $value = $s05.value; }
    | s06=case_statement[$label]                { $value = $s06.value; }
    | s07=loop_statement[$label]                { $value = $s07.value; }
    | s08=next_statement[$label]                { $value = $s08.value; }
    | s09=exit_statement[$label]                { $value = $s09.value; }
    | s10=return_statement[$label]              { $value = $s10.value; }
    | s11=null_statement[$label]                { $value = $s11.value; }
    | s12=procedure_call_statement[$label]      { $value = $s12.value; }
    ;

shift_expression returns [Expression value]
    :   ^( shift_operator l=shift_expression r=shift_expression )
        { $value = ExpressionTypeCreator.create($shift_operator.value, $l.value, $r.value); }
    |   simple_expression
        { $value = $simple_expression.value; }
    ;

shift_operator returns [ExpressionType value]
    :   SLL { $value = ExpressionType.SLL;}
    |   SRL { $value = ExpressionType.SRL;}
    |   SLA { $value = ExpressionType.SLA;}
    |   SRA { $value = ExpressionType.SRA;}
    |   ROL { $value = ExpressionType.ROL;}
    |   ROR { $value = ExpressionType.ROR;}
    ;

signal_assignment_statement[string label] returns [SignalAssignment value]
@after { AddAnnotations($value, $start); }
    :   ^( SIGNAL_ASSIGNMENT_STATEMENT target_signal delay_mechanism? waveform )
        {
            $value = new SignalAssignment($target_signal.value, $waveform.value);
            $value.Label = $label;
            $value.DelayMechanism = $delay_mechanism.value;
        }
    ;

signal_declaration returns [SignalDeclaration value]
@after 
{
	AddAnnotations($value, $start);
	$value.Parent = currentScope;
}
    :   ^( SIGNAL identifier_list subtype_indication signal_kind expression? )
        {
            List<Signal> signals = new List<Signal>();
            foreach (string identifier in $identifier_list.value)
            {
                Signal s = new Signal(identifier, $subtype_indication.value, $expression.value);
                s.Kind = $signal_kind.value;
                signals.Add(s);
            }
            $value = new SignalDeclaration(signals);
        }
    ;

signal_kind returns [Signal.KindEnum value]
    :   REGISTER { $value = Signal.KindEnum.REGISTER; }
    |   BUS      { $value = Signal.KindEnum.BUS; }
    |            { $value = Signal.KindEnum.DEFAULT; }
    ;

signal_list returns [DisconnectionSpecification.SignalList value]
@init { List<Signal> signals = new List<Signal>(); }
    :   ^( SIGNAL_LIST ( signal=name { signals.Add($signal.value.toSignal(currentScope)); } )+ )
        { $value = new DisconnectionSpecification.SignalList(signals); }
    |   OTHERS { $value = DisconnectionSpecification.SignalList.OTHERS; }
    |   ALL    { $value = DisconnectionSpecification.SignalList.ALL; }
    ;

signature returns [Signature value = new Signature();]
    :   ^( SIGNATURE 
            ( type_mark1=name { $value.ParameterTypes.Add($type_mark1.value.toTypeMark(currentScope)); } )*
            ( RETURN type_mark2=name { $value.ReturnType = $type_mark2.value.toTypeMark(currentScope); } )?
        )
    ;

simple_expression returns [Expression value]
@init {
    bool AddPlus = false;
    bool AddMinus = false;
}
@after {
    if (AddPlus) {
        $value = new Plus($value);
    }
    if (AddMinus) {
        $value = new Minus($value);
    }
}
    :   (
                PLUS  { AddPlus = true; }
            |   MINUS { AddMinus = true; }
        )?
        (
                ^( adding_operator l=simple_expression r=simple_expression )
                { $value = ExpressionTypeCreator.create($adding_operator.value, $l.value, $r.value); }
            |   t=term
                { $value = $t.value; }
        )
    ;

subprogram_body returns [SubprogramBody value]
@init { IDeclarativeRegion oldScope = currentScope; }
@after {
    currentScope = oldScope;
    AddAnnotations($value, $start);
}
    :   ^( SUBPROGRAM_BODY
            sp=subprogram_specification
            {
                if ($subprogram_specification.value is FunctionDeclaration)
                {
                    $value = new FunctionBody((FunctionDeclaration) $sp.value);
                }
                else
                 if ($subprogram_specification.value is ProcedureDeclaration)
                 {
                    $value = new ProcedureBody((ProcedureDeclaration) $sp.value);
                 }
                 else
                 {
                    throw new Exception("Illegal Expression");
                 }

                $value.Parent = oldScope;
                currentScope = $value;
            }
            ( sdi=subprogram_declarative_item { $value.Declarations.Add($sdi.value); } )*
            { AddListEndComments($sdi.value, $sdi.start); }
            ( ss=sequential_statement { $value.Statements.Add($ss.value); } )*
            { AddListEndComments($ss.value, $ss.start); }
        )
    ;

subprogram_declaration returns [SubprogramDeclaration value]
@after { AddAnnotations($value, $start); }
    :   ^( SUBPROGRAM_DECLARATION subprogram_specification )
        { $value = $subprogram_specification.value; }
    ;

subprogram_declarative_item returns [ISubprogramDeclarativeItem value]
    :   subprogram_declaration     { $value = $subprogram_declaration.value; }
    |   subprogram_body            { $value = $subprogram_body.value; }
    |   type_declaration           { $value = $type_declaration.value; }
    |   subtype_declaration        { $value = $subtype_declaration.value; }
    |   constant_declaration       { $value = $constant_declaration.value; }
    |   variable_declaration       { $value = $variable_declaration.value; }
    |   file_declaration           { $value = $file_declaration.value; }
    |   alias_declaration          { $value = $alias_declaration.value; }
    |   attribute_specification    { $value = $attribute_specification.value; }
    |   attribute_declaration      { $value = $attribute_declaration.value; }
    |   use_clause                 { $value = $use_clause.value; }
    |   group_template_declaration { $value = $group_template_declaration.value; }
    |   group_declaration          { $value = $group_declaration.value; }
    ;

subprogram_specification returns [SubprogramDeclaration value]
@init { bool impure = false; }
    :   ^( PROCEDURE
            designator { $value = new ProcedureDeclaration($designator.text); }
            ( id=interface_declaration { $value.Parameters.Add($id.value); } )*
        )
    |   ^( FUNCTION
            PURE? ( IMPURE { impure = true; } )? designator type_mark=name
            {
                ISubtypeIndication type = $type_mark.value.toTypeMark(currentScope);
                FunctionDeclaration fd = new FunctionDeclaration($designator.text, type);
                fd.Impure = impure;
                $value = fd;
            }
            ( id=interface_declaration { $value.Parameters.Add($id.value); } )*
        )
    ;

subtype_declaration returns [Subtype value]
@after { AddAnnotations($value, $start); }
    :   ^( SUBTYPE identifier subtype_indication )
        { $value = new Subtype($identifier.text, $subtype_indication.value); }
    ;

//TODO: fix name/constraint ambiguity
//TODO: remove unresolved type
subtype_indication returns [ISubtypeIndication value]
    :   ^( SUBTYPE_INDICATION
            type_mark=name { $value = $type_mark.value.toTypeMark(currentScope); }
            (
                resolution_function=name
                { $value = new ResolvedSubtypeIndication($resolution_function.value.toFunction(currentScope), $value); }
            )?
            (
                    range_constraint
                    { $value = new RangeSubtypeIndication($value, $range_constraint.value); }
                |   index_constraint
                    { $value = new IndexSubtypeIndication($value, $index_constraint.value); }
            )?
        )
    ;

suffix
    :   identifier
    |   CHARACTER_LITERAL
    |   STRING_LITERAL
    |   ALL
    ;

target_signal returns [ISignalAssignmentTarget value]
    :   signal=name { $value = $signal.value.toSignalTarget(currentScope); }
    |   aggregate { $value = $aggregate.value; }
    ;

target_variable returns [IVariableAssignmentTarget value]
    :   variable=name { $value = $variable.value.toVariableTarget(currentScope); }
    |   aggregate { $value = $aggregate.value; }
    ;

term returns [Expression value]
    :   ^( multiplying_operator l=term r=term )
        { $value = ExpressionTypeCreator.create($multiplying_operator.value, $l.value, $r.value); }
    |   factor
        { $value = $factor.value; }
    ;

type_declaration returns [VHDL.type.Type value]
    :   ^( FULL_TYPE_DECLARATION identifier type_definition[$identifier.text] )
        { $value = $type_definition.value; }
    |   ^( INCOMPLETE_TYPE_DECLARATION identifier )
        { $value = new IncompleteType($identifier.text); }
    ;

type_definition[String identifier] returns [VHDL.type.Type value]
    : ptd=physical_type_definition[$identifier]           { $value = $ptd.value; }
    | etd=enumeration_type_definition[$identifier]        { $value = $etd.value; }
    | ioftd=integer_or_float_type_definition[$identifier] { $value = $ioftd.value; }
    | uad=unconstrained_array_definition[$identifier]     { $value = $uad.value; }
    | cas=constrained_array_definition[$identifier]       { $value = $cas.value; }
    | rtd=record_type_definition[$identifier]             { $value = $rtd.value; }
    | atd=access_type_definition[$identifier]             { $value = $atd.value; }
    | ftd=file_type_definition[$identifier]               { $value = $ftd.value; }
    ;

unconstrained_array_definition[string ident] returns [UnconstrainedArray value]
@init { List<ISubtypeIndication> indexSubtypes = new List<ISubtypeIndication>(); }
@after { AddAnnotations($value, $start); }
    :   ^( UNCONSTRAINED_ARRAY_DEFINITION
            ( index_subtype=name { indexSubtypes.Add($index_subtype.value.toTypeMark(currentScope)); } )+
            element_type=subtype_indication
        )
        { $value = new UnconstrainedArray($ident, $element_type.value, indexSubtypes); }
    ;

//TODO: handle names differently
use_clause returns [UseClause value]
@init { List<string> names = new List<string>(); }
@after 
{
    $value = new UseClause(names);
    AddAnnotations($value, $start);
    CheckUseClause($use_clause.start, $value);
}
    :   ^( USE ( selected_name=name { names.Add($selected_name.value.toUseClauseName(currentScope)); } )+ )
    ;

variable_assignment_statement[string label] returns [VariableAssignment value]
@after { AddAnnotations($value, $start); }
    :   ^( VARIABLE_ASSIGNMENT_STATEMENT target_variable expression )
        {
            $value = new VariableAssignment($target_variable.value, $expression.value);
            $value.Label = $label;
        }
    ;

variable_declaration returns [VariableDeclaration value]
@init { bool isShared = false; }
@after 
{
	AddAnnotations($value, $start);
	$value.Parent = currentScope;
}
    :   ^( VARIABLE
            ( SHARED { isShared = true; } )?
            identifier_list subtype_indication expression?
        )
        {
            List<Variable> variables = new List<Variable>();
            foreach (string identifier in $identifier_list.value) {
                Variable v = new Variable(identifier, $subtype_indication.value, $expression.value);
                v.Shared = isShared;
                variables.Add(v);
            }
            $value = new VariableDeclaration(variables);
        }
    ;

wait_statement[string label] returns [WaitStatement value = new WaitStatement()]
@after { AddAnnotations($value, $start); }
    :   ^( WAIT
            { $value.Label = $label; }
            ( ^(ON sl=sensitivity_list) { AddRange($value.SensitivityList, $sl.value); } )?
            ( ^(UNTIL condition=expression) { $value.Condition = $condition.value; } )?
            ( ^(FOR timeout=expression) { $value.Timeout = $timeout.value; } )?
        )
    ;

waveform returns [List<WaveformElement> value = new List<WaveformElement>()]
    :   ^( WAVEFORM
            ( waveform_element { $value.Add($waveform_element.value); } )+
        )
    |   UNAFFECTED //return empty list
    ;

waveform_element returns [WaveformElement value]
    :   ^( WAVEFORM_ELEMENT
            val=expression { $value = new WaveformElement($val.value); }
            ( after=expression { $value.After = $after.value; } )?
        )
    ;

//----------

loop_label returns [LoopStatement value]
    :   identifier
        {
            $value = resolve<LoopStatement>($identifier.text);
            if ($value == null) {
                resolveError($identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_LOOP, $identifier.text);
                $value = new LoopStatement();
                $value.Label = $identifier.text;
            }
        }
    ;

package_simple_name returns [PackageDeclaration value]
    :   identifier
        {
            $value = resolve<PackageDeclaration>($identifier.text);
            if ($value == null) {
                resolveError($identifier.start, ParseError.ParseErrorTypeEnum.UNKNOWN_PACKAGE, $identifier.text);
                $value = new PackageDeclaration($identifier.text);
            }
        }
    ;
