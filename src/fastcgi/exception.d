module fastcgi.exception;

import std.exception;
import std.string;

class ConnectionException : Exception {
    this( string message, string file = __FILE__, size_t line = __LINE__ ){
        super( message, __FILE__, __LINE__ );
    }
}

class StreamException : Exception {
    this( string message, string file = __FILE__, size_t line = __LINE__ ){
        super( message, __FILE__, __LINE__ );
    }
}
