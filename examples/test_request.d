import std.string;

import fastcgi.request;

void main( string[] args ){
    Request request = new Request();
    while( request.accept() ){
        request.write( "Content-Type: text/html\n\n" );
        request.write( "charset=utf-8\n" );
        request.write( "<h1>Hello word</h1>\n" );
        request.writef( "Page: %s",  request.SCRIPT_FILENAME);
    }
}

