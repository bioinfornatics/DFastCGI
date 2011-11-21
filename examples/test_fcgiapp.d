import std.string;
import std.conv;
import std.c.process    : getpid;
import fastcgi.c.fcgiapp;

void main( string[] args ){
    FCGX_Stream*    streamIn;
    FCGX_Stream*    streamOut;
    FCGX_Stream*    streamErr;
    FCGX_ParamArray envp;
    int count = 0;
    while(FCGX_Accept(&streamIn, &streamOut, &streamErr, &envp) >= 0){
        int err = FCGX_Init(); /* call before Accept in multithreaded apps */
        FCGX_FPrintF(streamOut,
               "Content-type: text/html\n\n"
               "<title>FastCGI Hello! (D, fcgiapp library)</title>\n"
               "<h1>FastCGI Hello! (D, fcgiapp library)</h1>\n"
               "Request number %d running on host <i>%s</i>  "
               "Process ID: %d\n",
               ++count, FCGX_GetParam("SERVER_NAME", envp), getpid());
        string query    = to!string( FCGX_GetParam("QUERY_STRING", envp) );
        string host     = to!string( FCGX_GetParam("SERVER_NAME", envp) );
        string script   = to!string( FCGX_GetParam("SCRIPT_NAME", envp) );
        string path     = to!string( FCGX_GetParam("PATH", envp) );
        FCGX_FPrintF(   streamOut,
                        format("<div>Querry: %s</div><div>Server: %s</div><div>Script: %s</div><div>Path: %s</div>", query , host  , script, path ).toStringz
                    );
   }
}
