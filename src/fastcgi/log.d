module fastcgi.log;

import std.stdio;
import std.path;
import std.string;
import std.process;

const(string)  logFilePath = buildNormalizedPath("/", "var", "log", "DFastCGI", "log");

void logMessage( string[] messages...){
    bool    enableLogging   = false;
    string  env             = getenv("DFASTCGI_DEBUG");
    switch( env ){
        case("1"):
        case("true"):
        case("TRUE"):
            enableLogging = true;
            break;
        default:
            enableLogging   = false;
    }
    if( enableLogging ){
        File logFile = File( logFilePath, "a+" );
        foreach( message; messages )
            logFile.writeln( message );
    }
}
