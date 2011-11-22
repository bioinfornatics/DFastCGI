import std.string;

import fastcgi.request;
import fastcgi.application;

void testPage(Request request){
    request.write( "Content-type: text/html; charset=utf-8\n<h1>Hello word</h1>" );
}

void main( string[] args ){
    Application webApp = new Application();
    webApp.webPage( &testPage );
}

