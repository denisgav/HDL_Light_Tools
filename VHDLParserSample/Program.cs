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
using System.Linq;
using System.Text;
using VHDL;
using VHDL.parser;
using Antlr.Runtime;
using VHDL.libraryunit;
using System.Diagnostics;
using VHDLParser;
using System.Collections;


namespace ModelingSystemTest
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                VHDL_Library_Manager libraryManager = new VHDL_Library_Manager("", @"Libraries\LibraryRepository.xml");
                libraryManager.Logger.OnWriteEvent += new VHDLParser.Logger.OnWriteDeleagte(Logger_OnWriteEvent);
                libraryManager.LoadData(@"Libraries");
                VhdlParserSettings settings = VhdlParser.DEFAULT_SETTINGS;
                RootDeclarativeRegion rootScope = new RootDeclarativeRegion();
                LibraryDeclarativeRegion currentLibrary = new LibraryDeclarativeRegion("work");
                rootScope.Libraries.Add(currentLibrary);
                //rootScope.getLibraries().Add(VHDL_Library_Manager.GetLibrary("STD"));

                Console.WriteLine("Parsing code");
                VhdlFile file = VhdlParser.parseFile("simple_simulation.vhd", settings, rootScope, currentLibrary, libraryManager);
                Console.WriteLine("Parsing complete");                
            }
            catch (SyntaxExceptionScope ex)
            {
                Console.WriteLine(ex.Message);
                foreach (RecognitionException err in ex.Errors)
                {
                    Console.WriteLine(VhdlParser.errorToMessage(err));
                }
            }
            catch (SemanticExceptionScope ex)
            {
                Console.WriteLine(ex.Message);
                foreach (ParseError err in ex.Errors)
                {
                    Console.WriteLine(VhdlParser.errorToMessage(err));
                }
            }
            /*
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            Console.WriteLine(ex.Source);
            Console.WriteLine(ex.StackTrace);
        }
            */
            Console.ReadKey();
        }

        static void Logger_OnWriteEvent(VHDLParser.LoggerMessageVerbosity verbosity, string message)
        {
            Console.WriteLine(String.Format("[{0}] {1}", verbosity, message));
        }
    }
}
