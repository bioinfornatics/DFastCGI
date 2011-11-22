import std.string;
import std.conv;
import std.c.process    : getpid;
import fastcgi.c.fcgiapp;

void main( string[] args ){
    FCGX_Request request;
    int err         = 0;
    int count       = 0;
    string message  = "<div>D powaaa</div>";
    err = FCGX_Init();
    err = FCGX_InitRequest(&request, 0, 0);
    while(FCGX_Accept_r(&request) >= 0){
        //int err = FCGX_Init(); /* call before Accept in multithreaded apps */
        FCGX_FPrintF(request.streamOut,
               "Content-type: text/html\n\n"
               "<title>FastCGI Hello! (D, fcgiapp library)</title>\n"
               "<h1>FastCGI Hello! (D, fcgiapp library)</h1>\n"
               "Request number %d running on host <i>%s</i>  "
               "Process ID: %d\n",
               ++count, FCGX_GetParam("SERVER_NAME", request.envp), getpid());
        string query    = to!string( FCGX_GetParam("QUERY_STRING", request.envp) );
        string host     = to!string( FCGX_GetParam("SERVER_NAME", request.envp) );
        string script   = to!string( FCGX_GetParam("SCRIPT_NAME", request.envp) );
        string path     = to!string( FCGX_GetParam("PATH", request.envp) );
        FCGX_FPrintF(   request.streamOut,
                        format("<div>Querry: %s</div><div>Server: %s</div><div>Script: %s</div><div>Path: %s</div>", query , host  , script, path ).toStringz
                    );
        FCGX_PutStr( message.toStringz, cast(int)message.length, request.streamOut );
   }
}
