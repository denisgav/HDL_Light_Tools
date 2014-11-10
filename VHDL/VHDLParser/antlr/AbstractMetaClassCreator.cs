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
using System.Collections.Generic;

namespace VHDL.parser.antlr
{
    using Antlr.Runtime.Tree;
    using Antlr.Runtime;
    using VHDL.builtin;
    using VHDL.concurrent;
    using VHDL.statement;
    using VHDL.libraryunit;
    using VHDL.expression;

    using Annotations = VHDL.Annotations;
    using DeclarativeRegion = VHDL.IDeclarativeRegion;
    using LibraryDeclarativeRegion = VHDL.LibraryDeclarativeRegion;
    using RootDeclarativeRegion = VHDL.RootDeclarativeRegion;
    using VhdlElement = VHDL.VhdlElement;
    using DeclarativeItemMarker = VHDL.declaration.IDeclarativeItemMarker;
    using VhdlParserSettings = VHDL.parser.VhdlParserSettings;
    using ParseError = VHDL.parser.ParseError;
    using PositionInformation = VHDL.annotation.PositionInformation;
    using SourcePosition = VHDL.annotation.SourcePosition;
    using Comments = VHDL.util.Comments;
    
    /// <summary>
    /// Abstract base class for the meta class creator.
    /// </summary>
    public class AbstractMetaClassCreator : TreeParser
    {

        private readonly List<ParseError> errors = new List<ParseError>();
        protected internal DeclarativeRegion currentScope;
        protected internal readonly VhdlParserSettings settings;
        protected internal readonly LibraryDeclarativeRegion libraryScope;
        protected internal readonly RootDeclarativeRegion rootScope;
        protected internal VHDL_Library_Manager libraryManager;

        /// <summary>
        /// Path to the file (optional)
        /// </summary>
        private string fileName;
        public string FileName
        {
            get { return fileName; }
            set { fileName = value; }
        }



        public AbstractMetaClassCreator(ITreeNodeStream input, RecognizerSharedState state)
            : base(input, state)
        {
            throw new Exception("Don't call the default ANTLR constructors");
        }

        public AbstractMetaClassCreator(ITreeNodeStream input)
            : base(input)
        {
            throw new Exception("Don't call the default ANTLR constructors");
        }

        public AbstractMetaClassCreator(ITreeNodeStream input, VhdlParserSettings settings, RootDeclarativeRegion rootScope, LibraryDeclarativeRegion libraryScope, VHDL_Library_Manager libraryManager)
            : base(input)
        {
            this.settings = settings;
            this.rootScope = rootScope;
            this.libraryScope = libraryScope;
            this.libraryScope.Parent = rootScope;
            fileName = string.Empty;
            this.libraryManager = libraryManager;
        }

        public AbstractMetaClassCreator(ITreeNodeStream input, VhdlParserSettings settings, RootDeclarativeRegion rootScope, LibraryDeclarativeRegion libraryScope, VHDL_Library_Manager libraryManager, string fileName)
            : this(input, settings, rootScope, libraryScope, libraryManager)
        {
            this.fileName = fileName;
        }

        protected internal virtual VhdlParserSettings Settings
        {
            get { return settings; }
        }

        protected internal virtual T resolve<T>(string identifier) where T : class
        {
            if (currentScope != null)
            {
                return currentScope.Scope.resolve<T>(identifier);
            }

            return null;
        }

        private SourcePosition tokenToPosition(IToken token, bool start)
        {
            CommonToken t = (CommonToken)token;
            int index = start ? t.StartIndex : t.StopIndex;
            return new SourcePosition(t.Line, t.CharPositionInLine, index);
        }

        private PositionInformation treeToPosition(ITree tree)
        {
            ITokenStream tokens = input.TokenStream;
            CommonToken Start = (CommonToken)tokens.Get(tree.TokenStartIndex);
            CommonToken Stop = (CommonToken)tokens.Get(tree.TokenStopIndex);
            //string fileName = this.

            return new PositionInformation(fileName, tokenToPosition(Start, true), tokenToPosition(Stop, false));
        }

        protected internal virtual void resolveError(ITree tree, ParseError.ParseErrorTypeEnum type, string identifier)
        {
            if (settings.EmitResolveErrors)
            {
                PositionInformation pos = treeToPosition(tree);
                errors.Add(new ParseError(pos, type, identifier));
            }
        }

        public virtual List<ParseError> getErrors()
        {
            return errors;
        }

        private void AddPositionAnnotation(VhdlElement element, CommonTree tree)
        {
            PositionInformation info = treeToPosition(tree);
            Annotations.putAnnotation(element, info);
        }

        private void AddCommentAnnotation(VhdlElement element, CommonTree tree)
        {
            LinkedList<string> comments = null;

            for (int i = tree.TokenStartIndex - 1; i >= 0; i--)
            {
                IToken t = input.TokenStream.Get(i);

                if (t.Channel == VhdlAntlrLexer.CHANNEL_COMMENT)
                {
                    if (comments == null)
                    {
                        comments = new LinkedList<string>();
                    }

                    string text = t.Text.Substring(2); //strip leading "--"
                    comments.AddFirst(text);
                }
                else if (t.Channel != VhdlAntlrLexer.Hidden)
                {
                    break;
                }
            }

            if (comments != null && comments.Count != 0)
            {
                Comments.SetComments(element, new List<string>(comments));
            }
        }

        protected internal virtual void AddListEndComments(DeclarativeItemMarker item, ITree tree)
        {
            if (item is VhdlElement)
            {
                AddListEndComments((VhdlElement)item, tree);
            }
        }

        protected internal virtual void AddListEndComments(VhdlElement element, ITree tree)
        {
            if (tree == null)
            {
                return;
            }

            List<string> comments = null;

            for (int i = tree.TokenStopIndex + 1; i < input.TokenStream.Count; i++)
            {
                IToken t = input.TokenStream.Get(i);

                if (t.Channel == VhdlAntlrLexer.CHANNEL_COMMENT)
                {
                    if (comments == null)
                    {
                        comments = new List<string>();
                    }

                    string text = t.Text.Substring(2); //strip leading "--"
                    comments.Add(text);
                }
                else if (t.Channel != VhdlAntlrLexer.Hidden)
                {
                    break;
                }
            }

            if (comments != null && comments.Count != 0)
            {
                Comments.SetCommentsAfter(element, comments);
            }
        }

        protected internal virtual void AddAnnotations(VhdlElement element, CommonTree tree)
        {
            if (element == null || tree == null)
            {
                return;
            }

            if (settings.AddPositionInformation)
            {
                AddPositionAnnotation(element, tree);
            }

            if (settings.ParseComments)
            {
                AddCommentAnnotation(element, tree);
            }
        }

        public static void AddRange<E>(IList<E> collection1, IList<E> collection2) where E : class
        {
            foreach (E e in collection2)
                collection1.Add(e);
        }

        protected LibraryDeclarativeRegion LoadLibrary(string library)
        {
            //if (library.Equals("IEEE", StringComparison.CurrentCultureIgnoreCase))
            //    return builtin.Libraries.IEEE;
            //return null;
            if (libraryScope.Identifier.Equals(library, StringComparison.InvariantCultureIgnoreCase))
                return libraryScope;
            return libraryManager.GetLibrary(library);
        }

        /// <summary>
        /// Проверка процесса на содержание операторов Wait
        /// </summary>
        /// <param name="tree"></param>
        /// <param name="process"></param>
        public bool CheckProcess(ITree tree, ProcessStatement process)
        {
            int WaitCount = 0;
            foreach (SequentialStatement SeqStatement in process.Statements)
            {
                WaitCount += GetWaitCount(SeqStatement);
            }
            if (process.SensitivityList.Count > 0)
            { // no wait statement
                if (WaitCount > 0)
                {
                    resolveError(tree, ParseError.ParseErrorTypeEnum.PROCESS_TYPE_ERROR, "wait statement not allowed");
                    return false;
                }
            }
            else
            { // at least one wait statement
                if (WaitCount == 0)
                {
                    resolveError(tree, ParseError.ParseErrorTypeEnum.PROCESS_TYPE_ERROR, "wait statement required");
                    return false;
                }
            }
            return true;
        }

        /// <summary>
        /// Проверка оператора use (поиск соответствующего пакета или элемента пакета)
        /// </summary>
        /// <param name="tree"></param>
        /// <param name="useClause"></param>
        public bool CheckUseClause(ITree tree, UseClause useClause)
        {
            List<string> declarations = useClause.getDeclarations();
            foreach (string declaration in declarations)
            {
                string[] elems = declaration.Split(new char[] { '.' }, StringSplitOptions.RemoveEmptyEntries);
                if ((elems != null) && (elems.Length == 3))
                {
                    //Ищем библиотеку
                    string libraryName = elems[0];
                    IList<LibraryDeclarativeRegion> libraries = rootScope.Libraries;
                    foreach (LibraryDeclarativeRegion library in libraries)
                    {
                        if ((library != null) && (library.Identifier.Equals(libraryName, StringComparison.InvariantCultureIgnoreCase)))
                        {
                            //Нашли необходимую библиотеку
                            //Ищем пакет
                            string packageName = elems[1];
                            foreach (VhdlFile file in library.Files)
                            {
                                foreach (LibraryUnit unit in file.Elements)
                                {
                                    if (unit is PackageDeclaration)
                                    {
                                        PackageDeclaration packege = unit as PackageDeclaration;
                                        if (packege.Identifier.Equals(packageName, StringComparison.InvariantCultureIgnoreCase))
                                        {
                                            //Нашли необходимый пакет
                                            //Ищем нужный элемент
                                            string elemName = elems[2];
                                            if (elemName.Equals("all", StringComparison.InvariantCultureIgnoreCase))
                                            {
                                                if (useClause.LinkedElements.Contains(packege) == false)
                                                    useClause.LinkedElements.Add(packege);
                                                return true;
                                            }
                                            object o = packege.Scope.resolveLocal(elemName);
                                            if ((o != null) && (o is INamedEntity))
                                            {
                                                INamedEntity el = o as INamedEntity;
                                                if (useClause.LinkedElements.Contains(el) == false)
                                                    useClause.LinkedElements.Add(el);
                                                return true;
                                            }
                                            else
                                            {
                                                resolveError(tree, ParseError.ParseErrorTypeEnum.UNKNOWN_OTHER, "Incorrect use clause (item )");
                                                return false;
                                            }
                                        }
                                    }
                                }
                            }
                            resolveError(tree, ParseError.ParseErrorTypeEnum.UNKNOWN_OTHER, "Incorrect use clause (primary unit name )");
                            return false;
                        }
                    }
                    resolveError(tree, ParseError.ParseErrorTypeEnum.UNKNOWN_OTHER, "Incorrect use clause (library name)");
                    return false;
                }
                else
                {
                    resolveError(tree, ParseError.ParseErrorTypeEnum.UNKNOWN_PACKAGE, "Incorrect use clause");
                    return false;
                }
            }
            return true;
        }

        /// <summary>
        /// Проверка наличия библиотеки
        /// </summary>
        /// <param name="tree"></param>
        /// <param name="useClause"></param>
        public bool CheckLibraryClause(ITree tree, LibraryClause libraryClause)
        {
            foreach (string lib in libraryClause.getLibraries())
            {
                if (libraryManager.ContainsLibrary(lib) == false)
                {
                    resolveError(tree, ParseError.ParseErrorTypeEnum.UNKNOWN_OTHER, string.Format("Incorrect library clause, unknown library {0})", lib));
                    return false;
                }
                else
                {
                    LibraryDeclarativeRegion libraryDecl = libraryManager.GetLibrary(lib);
                    if (libraryClause.LibraryDeclarativeRegion.Contains(libraryDecl) == false)
                        libraryClause.LibraryDeclarativeRegion.Add(libraryDecl);
                }
            }
            return true;
        }

        private int GetWaitCount(SequentialStatement SeqStatement)
        {
            int WaitCount = 0;
            if (SeqStatement is WaitStatement)
                return 1;
            foreach (VhdlElement el in SeqStatement.GetAllStatements())
                if (el is SequentialStatement)
                    WaitCount += GetWaitCount(el as SequentialStatement);
            return WaitCount;
        }
    }
}