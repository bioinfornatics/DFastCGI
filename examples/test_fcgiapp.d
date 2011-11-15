import std.string;
import std.stdio;
import fastcgi.c.fcgiapp;
import std.c.process;

void main( string[] args ){
    FCGX_Stream*    streamIn;
    FCGX_Stream*    streamOut;
    FCGX_Stream*    streamErr;
    FCGX_ParamArray envp;
    int count = 0;
    while(FCGX_Accept(&streamIn, &streamOut, &streamErr, &envp) >= 0){
        debug writeln( "CGI Loop" );
        int err = FCGX_Init(); /* call before Accept in multithreaded apps */
        FCGX_FPrintF(streamOut,
               "Content-type: text/html\n\n"
               "<title>FastCGI Hello! (D, fcgiapp library)</title>\n"
               "<h1>FastCGI Hello! (D, fcgiapp library)</h1>\n"
               "Request number %d running on host <i>%s</i>  "
               "Process ID: %d\n",
               ++count, FCGX_GetParam("SERVER_NAME", envp), getpid());
   }
}
