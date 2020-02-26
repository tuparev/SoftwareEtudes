//
//  CommandParser.swift
//  
//
//  Created by Georg Tuparev on 09/02/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//

import Foundation

/**
 POSIX and GNU style utility argument parser

 The documentation follows (partially copies) GNU's "Program Argument Syntax Conventions (see below).
 The implementation of the parser borrows ideas from other implementations, but it is complete,
 and simplifies standard UNIX commands by using the synopsis for initialisation. Another way to configure
 the parser (specially for macOS and iOS apps) is by providing a config file (JSON) instead of tedious argument
 after argument initialisation.

 ## Rules:
 - Arguments are options if they begin with a hyphen delimiter (‘-’)
 - Multiple options may follow a hyphen delimiter in a single token if the options do not take
 arguments. Thus, ‘-abc’ is equivalent to ‘-a -b -c’
 - Option names are single alphanumeric characters
 - Certain options require an argument. For example, the ‘-o’ command of the ld command requires
 an argument - an output file name
 - An option and its argument may or may not appear as separate tokens. (In other words, the
 whitespace separating them is optional but highly recommended). Thus, ‘-o foo’ and ‘-ofoo’ are
 equivalent
 - Options typically precede other non-option arguments (default parser behaviour)
 - The argument ‘--’ followed by space ' ' terminates all options; any following arguments are
 treated as non-option arguments, even if they begin with a hyphen
 - A token consisting of a single hyphen character is interpreted as an ordinary non-option
 argument. By convention, it is used to specify input from or output to the standard input
 and output stream
 - Options may be supplied in any order, or appear multiple times. The interpretation is left up
 to the particular application program
 - Long options consist of ‘--’ followed by a name made of alphanumeric characters and dashes.
 Option names are typically one to three words long, with hyphens to separate words. Users can
 abbreviate the option names as long as the abbreviations are unique. To specify an argument
 for a long option, write ‘--name=value’. This syntax enables a long option to accept an
 argument that is itself optional. The ‘--name value’ form is also allowed, but could be misleading

 ## Synopsis
 The parser could be initialised with a synopsis, typical for most unix man-pages, e.g.
 <utility_name> [-a] [-ab] [-c option_argument] [-d|-e] {[-n] [--name] option_argument} [operand ...]
 where:
 - <utility_name> - utility or command name. If not specified the first argument will be used
 - [-a] - example for option
 - [-ab] - example for multiple options (equivalent to -a -b)
 - [-d|-e] - example for mutually-exclusive options
 - [-c option_argument [option_argument...]] - example for option with one or more arguments
 - {[-n] [--name] option_argument} - example for long and short option with the same meaning
 If not specified, all arguments after the last option will be treated as operands.

 ## Raw and computed arguments
 //TODO: Write a description

 ## Examples for synopsis
 - "" - Empty, the parser will try build the synopsis based on the command line arguments
 - "<convert2bin> -i input_file" - use convert2bin as utility name with a single required option and
 argument

 ## Notes:
 - The parser could be used for command interpreters as well
 - The Swift Package Manager (ArgumentsKit): https://github.com/crelies/ArgumentParserKit was considered,
 but discarded as possible parser because of obvious lack of support for synopsis and many other Unix conventions.

 ## Links:
 - GNU arguments: https://www.gnu.org/software/libc/manual/html_node/Argument-Syntax.html
 - POSIX arguments: http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html
 */
public class CommandParser {

    /// Creates an empty string.
    ///
    /// Using this initialiser is equivalent to initialising a command parser with an
    /// empty string command.
    @inlinable public init() { }


    /// The complete command to be parsed. It must me set before `parse()`. It is preferred to be set with one of
    /// the initialisers.
    public var command = ""

    private var didParse = false
    private var _commandName: String?
    private var _parsedTokens: [String] = []


    public func parse() -> Bool {  //TODO: Should return a Result type
        _parsedTokens = command.components(separatedBy: " ")

        //TODO: Implement me!

        didParse = true

        return false
    }

    /// Returns the command or utility name, or nil if the command is not parsed or cannot be tokenised
    public func commandName() -> String? { _commandName }
}
