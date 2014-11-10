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
using System;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using Antlr.Runtime;
using Antlr.Runtime.Tree;
using VHDLParser.antlr;

namespace VHDL.parser
{
    using Annotations = VHDL.Annotations;
    using LibraryDeclarativeRegion = VHDL.LibraryDeclarativeRegion;
    using RootDeclarativeRegion = VHDL.RootDeclarativeRegion;
    using CaseInsensitiveInputStream = VHDL.parser.util.CaseInsensitiveInputStream;
    using CaseInsensitiveStringStream = VHDL.parser.util.CaseInsensitiveStringStream;
    using CaseInsensitiveFileStream = VHDL.parser.util.CaseInsensitiveFileStream;
    using VhdlFile = VHDL.VhdlFile;
    using ParseErrors = VHDL.parser.annotation.ParseErrors;

    /// <summary>
    /// VHDL parser.
    /// </summary>
    public class VhdlParser
    {
        public static readonly VhdlParserSettings DEFAULT_SETTINGS = new VhdlParserSettings();

        /// <summary>
        /// Prevent instantiation.
        /// </summary>
        private VhdlParser()
        {
        }

        private static VhdlFile parse(VhdlParserSettings settings, ICharStream stream, RootDeclarativeRegion rootScope, LibraryDeclarativeRegion libraryScope, VHDL_Library_Manager libraryManager)
        {
            VhdlAntlrLexer lexer = new VhdlAntlrLexer(stream);
            CommonTokenStream ts = new CommonTokenStream(lexer);

            VhdlAntlrParser parser = new VhdlAntlrParser(ts);
            parser.TreeAdaptor = new TreeAdaptorWithoutErrorNodes();

            AstParserRuleReturnScope<CommonTree, IToken> result;
            try
            {
                result = parser.design_file();
            }
            catch (RecognitionException ex)
            {
                throw new VhdlParserException(ex.Message);
            }

            if (parser.Errors.Count != 0)
            {
                throw new SyntaxExceptionScope("Parsing failed", parser.Errors);
            }

            CommonTreeNodeStream nodes = new CommonTreeNodeStream(result.Tree);
            nodes.TokenStream = ts;

            MetaClassCreator mcc = new MetaClassCreator(nodes, settings, rootScope, libraryScope, libraryManager) { FileName = stream.SourceName };

            if (stream is CaseInsensitiveStringStream)
            {
                mcc.FileName = (stream as CaseInsensitiveStringStream).FileName;
            }

            VhdlFile file = null;
            try
            {
                file = mcc.design_file();
            }
            catch (RecognitionException ex)
            {
                throw new VhdlParserException(ex.Message);
            }

            if (mcc.getErrors().Count != 0)
            {
                List<ParseError> errors = mcc.getErrors();
                Annotations.putAnnotation(file, new ParseErrors(errors));
                if (settings.PrintErrors)
                {
                    reportErrors(errors);
                }
                throw new SemanticExceptionScope("Parsing Failed", errors);
            }

            return file;
        }

        private static VhdlFile parse(VhdlParserSettings settings, ICharStream stream, VHDL_Library_Manager libraryManager)
        {
            RootDeclarativeRegion rootScope = new RootDeclarativeRegion();
            LibraryDeclarativeRegion libraryScope = new LibraryDeclarativeRegion("work");
            rootScope.Libraries.Add(libraryScope);

            return parse(settings, stream, rootScope, libraryScope, libraryManager);
        }

        public static VhdlFile parseFile(string fileName, VHDL_Library_Manager libraryManager)
        {
            return parseFile(fileName, DEFAULT_SETTINGS, libraryManager);
        }

        public static VhdlFile parseFile(string fileName, VhdlParserSettings settings, VHDL_Library_Manager libraryManager)
        {
            return parse(settings, new CaseInsensitiveFileStream(fileName), libraryManager);
        }

        public static VhdlFile parseFile(string fileName, VhdlParserSettings settings, RootDeclarativeRegion rootScope, LibraryDeclarativeRegion libray, VHDL_Library_Manager libraryManager)
        {
            return parse(settings, new CaseInsensitiveFileStream(fileName), rootScope, libray, libraryManager);
        }

        public static VhdlFile parseString(string str, VHDL_Library_Manager libraryManager)
        {
            return parseString(str, DEFAULT_SETTINGS, libraryManager);
        }

        public static VhdlFile parseString(string str, VhdlParserSettings settings, RootDeclarativeRegion rootScope, LibraryDeclarativeRegion libray, VHDL_Library_Manager libraryManager)
        {
            return parse(settings, new CaseInsensitiveStringStream(str), rootScope, libray, libraryManager);
        }

        public static VhdlFile parseString(string str, VhdlParserSettings settings, VHDL_Library_Manager libraryManager)
        {
            return parse(settings, new CaseInsensitiveStringStream(str), libraryManager);
        }

        public static VhdlFile parseStream(Stream stream, VHDL_Library_Manager libraryManager)
        {
            return parseStream(stream, DEFAULT_SETTINGS, libraryManager);
        }

        public static VhdlFile parseStream(Stream stream, VhdlParserSettings settings, VHDL_Library_Manager libraryManager)
        {
            return parse(settings, new CaseInsensitiveInputStream(stream), libraryManager);
        }

        public static VhdlFile parseStream(Stream stream, VhdlParserSettings settings, RootDeclarativeRegion rootScope, LibraryDeclarativeRegion libray, VHDL_Library_Manager libraryManager)
        {
            return parse(settings, new CaseInsensitiveInputStream(stream), rootScope, libray, libraryManager);
        }

        public static bool hasParseErrors(VhdlFile file)
        {
            return Annotations.getAnnotation<ParseErrors>(file) != null;
        }

        public static List<ParseError> getParseErrors(VhdlFile file)
        {
            ParseErrors errors = Annotations.getAnnotation<ParseErrors>(file);
            if (errors == null)
            {
                return new List<ParseError>();
            }
            else
            {
                return errors.Errors;
            }
        }

        public static string errorToMessage(RecognitionException ex)
        {
            if (ex is MissingTokenException)
            {
                MissingTokenException exception = (MissingTokenException)ex;
                if (exception.MissingType != -1)
                    return string.Format("Syntax error at position:{0},{1}. Missing character {2} in clause of {3}", exception.Line, exception.CharPositionInLine, /*FormatExceptionText(((CommonToken)exception.Inserted).Text)*/FormatExceptionText(MetaClassCreator.tokenNames[exception.MissingType]), exception.Token.Text);
                else
                    return string.Format("Syntax error at position:{0},{1}. Error in clause of {2}", exception.Line, exception.CharPositionInLine, exception.Token.Text);
            }
            if (ex is UnwantedTokenException)
            {
                UnwantedTokenException exception = (UnwantedTokenException)ex;
                if (exception.Expecting != -1)
                    return string.Format("Syntax error at position:{0},{1}. Extraneous character {2}. Expecting character {3}", exception.Line, exception.CharPositionInLine, exception.Token.Text, FormatExceptionText(exception.TokenNames[exception.Expecting]));
                else
                    return string.Format("Syntax error at position:{0},{1}. Extraneous character {2}", exception.Line, exception.CharPositionInLine, exception.Token.Text);
            }
            if (ex is MismatchedTokenException)
            {
                MismatchedTokenException exception = (MismatchedTokenException)ex;
                if (exception.Expecting != -1)
                    return string.Format("Syntax error at position:{0},{1}. Mismatched construction {2} in clause of {3}", exception.Line, exception.CharPositionInLine, /*FormatExceptionText(((CommonToken)exception.Inserted).Text)*/FormatExceptionText(MetaClassCreator.tokenNames[exception.Expecting]), exception.Token.Text);
                else
                    return string.Format("Syntax error at position:{0},{1}. Mismatched construction in clause of {2}", exception.Line, exception.CharPositionInLine, exception.Token.Text);
                //return string.Format("ExceptionType:{0} Message:{1}: Position: {2}, {3}; Token: {4}", exception.GetType(), exception.Message, exception.Line, exception.CharPositionInLine, exception.Token.Text);
            }
            if (ex is MismatchedNotSetException)
            {
                MismatchedNotSetException exception = (MismatchedNotSetException)ex;
                return string.Format("Syntax error at position:{0},{1}. Mismatched input {2} expecting set {3}", exception.Line, exception.CharPositionInLine, exception.Token.Text, exception.Expecting);

            }
            if (ex is MismatchedSetException)
            {
                MismatchedSetException exception = (MismatchedSetException)ex;
                //mismatched input 'if' expecting set null
                return string.Format("Syntax error at position:{0},{1}. Mismatched input {2} expecting set {3}", exception.Line, exception.CharPositionInLine, exception.Token.Text, exception.Expecting);

            }
            if (ex is EarlyExitException)
            {
                EarlyExitException exception = (EarlyExitException)ex;
                return string.Format("Syntax error at position:{0},{1}. Required (...)+ loop did not match anything at character {2}", exception.Line, exception.CharPositionInLine, exception.Token.Text);

            }
            if (ex is NoViableAltException)
            {
                NoViableAltException exception = (NoViableAltException)ex;
                return string.Format("Syntax error at position: {0}, {1} - some illegal character {2}. Check syntax of token.", exception.Line, exception.CharPositionInLine, exception.Token.Text);
            }
            if (ex is FailedPredicateException)
            {
                FailedPredicateException exception = (FailedPredicateException)ex;
                return string.Format("Syntax error at position:{0},{1}. Rule {2} failed predicate: {\"{3}\"}?", exception.Line, exception.CharPositionInLine, exception.RuleName, exception.PredicateText);

            }
            if (ex is MismatchedTreeNodeException)
            {
                MismatchedTreeNodeException exception = (MismatchedTreeNodeException)ex;
                string tokenName = "<unknown>";
                if (exception.Expecting == TokenTypes.EndOfFile)
                {
                    tokenName = "EndOfFile";
                }
                else
                {
                    tokenName = MetaClassCreator.tokenNames[exception.Expecting];
                }
                // workaround for a .NET framework bug (NullReferenceException)
                string nodeText = (exception.Node != null) ? exception.Node.ToString() ?? string.Empty : string.Empty;
                return string.Format("Syntax error at position:{0},{1}. Mismatched tree node: {2} expecting {3}", exception.Line, exception.CharPositionInLine, nodeText, tokenName);

            }
            if (ex is MismatchedRangeException)
            {
                MismatchedRangeException exception = (MismatchedRangeException)ex;
                return string.Format("Syntax error at position:{0},{1}. Mismatched character {2} expecting set {3} {4}", exception.Line, exception.CharPositionInLine, exception.Token.Text, exception.A, exception.B);

            }
            return string.Format("{0}: Position: {1}, {2}", ex.Message, ex.Line, ex.CharPositionInLine);
        }

        private static string FormatExceptionText(string error_string)
        {
            Dictionary<string, string> tokens = new Dictionary<string, string>();
            tokens.Add("DOUBLESTAR", "**");
            tokens.Add("LE", "<=");
            tokens.Add("GE", ">=");
            tokens.Add("ARROW", "=>");
            tokens.Add("NEQ", "/=");
            tokens.Add("VARASGN", ":=");
            tokens.Add("BOX", "<>");
            tokens.Add("DBLQUOTE", "\"");
            tokens.Add("SEMI", ";");
            tokens.Add("COMMA", ",");
            tokens.Add("AMPERSAND", "&");
            tokens.Add("LPAREN", "(");
            tokens.Add("RPAREN", ")");
            tokens.Add("LBRACKET", "[");
            tokens.Add("RBRACKET", "]");
            tokens.Add("COLON", ":");
            tokens.Add("MUL", "*");
            tokens.Add("DIV", "/");
            tokens.Add("PLUS", "+");
            tokens.Add("MINUS", "-");
            tokens.Add("LT", "<");
            tokens.Add("GT", ">");
            tokens.Add("EQ", "=");
            tokens.Add("BAR", "|");
            tokens.Add("EXCLAMATION", "!");
            tokens.Add("DOT", ".");
            tokens.Add("BACKSLASH", "\\");
            tokens.Add("EOF", "end of file");

            foreach (KeyValuePair<string, string> pair in tokens)
            {
                error_string = Regex.Replace(error_string, pair.Key, pair.Value);
            }
            return error_string;
        }

        public static string errorToMessage(ParseError error)
        {
            switch (error.Type)
            {
                case ParseError.ParseErrorTypeEnum.UNKNOWN_COMPONENT:
                    return string.Format("Line: {0}, {1} - unknown component: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_CONFIGURATION:
                    return string.Format("Line: {0}, {1} - unknown configuration: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_CONSTANT:
                    return string.Format("Line: {0}, {1} - unknown constant: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_ENTITY:
                    return string.Format("Line: {0}, {1} - unknown entity: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_FILE:
                    return string.Format("Line: {0}, {1} - unknown file: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_LOOP:
                    return string.Format("Line: {0}, {1} - unknown loop: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_CASE:
                    return string.Format("Line: {0}, {1} - unknown case: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_IF:
                    return string.Format("Line: {0}, {1} - unknown if: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_OTHER:
                    return string.Format("Line: {0}, {1} - unknown identifier: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_PROCESS:
                    return string.Format("Line: {0}, {1} - unknown process: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_PACKAGE:
                    return string.Format("Line: {0}, {1} - unknown pacakge: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_SIGNAL:
                    return string.Format("Line: {0}, {1} - unknown signal: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_SIGNAL_ASSIGNMENT_TARGET:
                    return string.Format("Line: {0}, {1} - unknown signal assignment target: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_TYPE:
                    return string.Format("Line: {0}, {1} - unknown type: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_VARIABLE:
                    return string.Format("Line: {0}, {1} - unknown variable: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_VARIABLE_ASSIGNMENT_TARGET:
                    return string.Format("Line: {0}, {1} - unknown variable assignment target: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.PROCESS_TYPE_ERROR:
                    return string.Format("Line: {0}, {1} - process type error: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_ARCHITECTURE:
                    return string.Format("Line: {0}, {1} - unknown architecture: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                case ParseError.ParseErrorTypeEnum.UNKNOWN_GENERATE_STATEMENT:
                    return string.Format("Line: {0}, {1} - unknown generate statement: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
                default:
                    return string.Format("Line: {0}, {1} - unknown error: {2}", error.Position.Begin.Line, error.Position.Begin.Column, error.Message);
            }
        }

        private static void reportErrors(List<ParseError> errors)
        {
            foreach (ParseError error in errors)
            {
                Console.Error.WriteLine("line " + error.Position.Begin.Line + ": " + errorToMessage(error));
            }

        }

        public class TreeAdaptorWithoutErrorNodes : CommonTreeAdaptor
        {

            public object errorNode(ITokenStream input, IToken start, IToken stop, RecognitionException e)
            {
                return null;
            }
        }
    }

}