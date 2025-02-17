grammar LangiumGrammar hidden(WS, SL_COMMENT, ML_COMMENT)

terminal WS         : /\s+/;
terminal ID returns string: /\^?[_a-zA-Z][\w_]*/;
terminal INT returns number: /[0-9]+/;
terminal string: /"[^"]*"|'[^']*'/;

terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
terminal SL_COMMENT: /\/\/[^\n\r]*/;

Grammar:
	'grammar' name=ID ('with' usedGrammars+=[Grammar|ID] (',' usedGrammars+=[Grammar|ID])*)?
	(definesHiddenTokens?='hidden' '(' (hiddenTokens+=[AbstractRule|ID] (',' hiddenTokens+=[AbstractRule|ID])*)? ')')?
	metamodelDeclarations+=AbstractMetamodelDeclaration*
	(rules+=AbstractRule)+;

AbstractRule : ParserRule | TerminalRule;

AbstractMetamodelDeclaration :
	GeneratedMetamodel | ReferencedMetamodel;

GeneratedMetamodel :
	'generate' name=ID ePackage=string ('as' alias=ID)?;

ReferencedMetamodel :
	'import' ePackage=string ('as' alias=ID)?;


Annotation:
	'@' name = ID;

ParserRule :
	(
	  ^fragment?='fragment' RuleNameAndParams (wildcard?='*' | ('returns' type=ID)?)
	| RuleNameAndParams ('returns' type=ID)?
	)
	(definesHiddenTokens?='hidden' '(' (hiddenTokens+=[AbstractRule|ID] (',' hiddenTokens+=[AbstractRule|ID])*)? ')')? ':'
		alternatives=Alternatives
	';';

fragment RuleNameAndParams:
	name=ID ('<' (parameters+=Parameter (',' parameters+=Parameter)*)? '>')?;

Parameter:
	name=ID;

Alternatives returns AbstractElement:
	UnorderedGroup ({Alternatives.elements+=current} ('|' elements+=UnorderedGroup)+)?;

UnorderedGroup returns AbstractElement:
	Group ({UnorderedGroup.elements+=current} ('&' elements+=Group)+)?;

Group returns AbstractElement:
	AbstractToken ({Group.elements+=current} elements+=AbstractToken+)?;

AbstractToken returns AbstractElement:
	AbstractTokenWithCardinality |
	Action;

AbstractTokenWithCardinality returns AbstractElement:
	(Assignment | AbstractTerminal) cardinality=('?'|'*'|'+')?;

Action returns AbstractElement:
	{Action} '{' type=ID ('.' feature=ID operator=('='|'+=') 'current')? '}';

AbstractTerminal returns AbstractElement:
	Keyword |
	RuleCall |
	ParenthesizedElement |
	PredicatedKeyword |
	PredicatedRuleCall |
	PredicatedGroup;

Keyword:
	value=string;

RuleCall:
	rule=[AbstractRule|ID] ('<' arguments+=NamedArgument (',' arguments+=NamedArgument)* '>')?;

NamedArgument:
	( parameter=[Parameter|ID] calledByName?= '=')?
	( value=Disjunction );

LiteralCondition:
	^true?='true' | 'false';

Disjunction returns Condition:
	Conjunction ({Disjunction.left=current} '|' right=Conjunction)?;

Conjunction returns Condition:
	Negation ({Conjunction.left=current} '&' right=Negation)?;

Negation returns Condition:
	Atom | {Negation} '!' value=Negation;

Atom returns Condition:
	ParameterReference | ParenthesizedCondition | LiteralCondition;

ParenthesizedCondition returns Condition:
	'(' Disjunction ')';

ParameterReference:
	parameter=[Parameter|ID];

TerminalRuleCall:
	rule=[AbstractRule|ID];

PredicatedKeyword returns Keyword:
	(predicated?='=>' | firstSetPredicated?='->') value=string;

PredicatedRuleCall returns RuleCall:
	(predicated?='=>' | firstSetPredicated?='->') rule=[AbstractRule|ID] ('<' arguments+=NamedArgument (',' arguments+=NamedArgument)* '>')?;

Assignment returns AbstractElement:
	{Assignment} (predicated?='=>' | firstSetPredicated?='->')? feature=ID operator=('+='|'='|'?=') ^terminal=AssignableTerminal;

AssignableTerminal returns AbstractElement:
	Keyword | RuleCall | ParenthesizedAssignableElement | CrossReference;

ParenthesizedAssignableElement returns AbstractElement:
	'(' AssignableAlternatives ')';

AssignableAlternatives returns AbstractElement:
	AssignableTerminal ({Alternatives.elements+=current} ('|' elements+=AssignableTerminal)+)?;

CrossReference returns AbstractElement:
	{CrossReference} '[' type=[ParserRule|ID] ('|' ^terminal=CrossReferenceableTerminal )? ']';

CrossReferenceableTerminal returns AbstractElement:
	Keyword | RuleCall;

ParenthesizedElement returns AbstractElement:
	'(' Alternatives ')';

PredicatedGroup returns Group:
	(predicated?='=>' | firstSetPredicated?='->') '(' elements+=Alternatives ')';

TerminalRule :
	'terminal' (^fragment?='fragment' name=ID | name=ID ('returns' type=ID)?) ':'
		regex=RegexLiteral
	';';

terminal RegexLiteral returns string: /\/(?![*+?])(?:[^\r\n\[/\\]|\\.|\[(?:[^\r\n\]\\]|\\.)*\])+\//;

TerminalAlternatives:
	TerminalGroup ({TerminalAlternatives.elements+=current} '|' elements+=TerminalGroup)*;

TerminalGroup:
	TerminalToken ({TerminalGroup.elements+=current} elements+=TerminalToken+)?;

TerminalToken:
	TerminalTokenElement cardinality=('?'|'*'|'+')?;

TerminalTokenElement:
	CharacterRange | TerminalRuleCall | ParenthesizedTerminalElement | AbstractNegatedToken | Wildcard;

ParenthesizedTerminalElement returns TerminalAlternatives:
	'(' TerminalAlternatives ')';

AbstractNegatedToken:
	NegatedToken | UntilToken;

NegatedToken:
	'!' ^terminal=TerminalTokenElement;

UntilToken:
	'->' ^terminal=TerminalTokenElement;

Wildcard:
	{Wildcard} '.';

CharacterRange:
	left=Keyword ('..' right=Keyword)?;

