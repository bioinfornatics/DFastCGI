import fastcgi.c.fcgi_stdio;
import std.process;

int count;

void initialize( ){
    count=0;
}

void main( string[] args ){
    /* Initialization. */
    initialize();

    /* Response loop. */
    while (FCGI_Accept() >= 0)   {
        printf("Content-type: text/html\r\n"
        "\r\n"
        "<title>FastCGI Hello! (D, fcgi_stdio library)</title>"
        "<h1>FastCGI Hello! (D, fcgi_stdio library)</h1>"
        "Request number %d running on host <i>%s</i>\n",
        ++count, getenv("SERVER_HOSTNAME"));
    }
}
