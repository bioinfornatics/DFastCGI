module fastcgi.request;
import std.string;
import std.conv;
import std.variant;

import fastcgi.c.fcgiapp;
import fastcgi.c.fastcgi;
import fastcgi.exception;
import fastcgi.connection;
import fastcgi.log;

class Request{
    private:
        string[string]  _params;
        Connection      _connection;
        FCGX_Request    _request;

        /**
         * isEndOfFile
         * Returns: true if it is end of stdin stream otherwise returns false
         */
        bool isEndOfFile(){
            return ( FCGX_HasSeenEOF( _request.streamIn ) == 0 ) ? false : true;
        }

    public:
        /**
         * Constructor
         * whath is the stream's type
         */
        this( Connection connection = null ){
            if (connection is null)
                connection = new Connection();

            _connection = connection;
            int err     = FCGX_InitRequest( &_request, connection.listenSocket, 0 );
            if( err != 0 ){
                string msg  = "Error: Request initialization failled";
                logMessage( msg );
                throw new FCGXException( msg );
            }
        }

        ~this(){
            finish();
            if( &_request !is null )
                FCGX_Free( &_request, 1);
        }

        @property Connection connection(){
            return _connection.dup;
        }

        @property void connection( Connection connection ){
            _connection = connection;
        }

        /**
         * accept
         * Initialize and accept a new request (multi-thread safe).
         * Returns: true for succefull call
         */
        bool accept(){
            return ( FCGX_Accept_r( &_request ) >= 0 ) ? true : false;
        }

        /**
         * readLine
         * TODO: Must call accept before getLine maybe need to check insde
         * Returns: return full line with \n
         */
        string readLine(){
            size_t  read_char   = 8192;
            bool    isRunning   = true;
            string  result      = "";
            while( isRunning ){
                int currentChar = FCGX_GetChar( _request.streamIn );
                if( currentChar == -1 )
                    isRunning = false;
                else if( isEndOfFile )
                    isRunning = false;
                else{
                    result ~= cast(char) currentChar;
                    if( result[ $ - 1 ] == '\n' )
                        isRunning = false;
                }
            }
            return result;
        }

        /**
         * lineByLine
         * this method allow to you, iterate over stream line by line
         * Example:
         * foreach( line; request.lineByLine )
         *     writefln( "current line: %s", line );
         */
        void byLine( int delegate(ref string) dg ){
            while( !isEndOfFile ){
                int result = 0;
                string line = readLine();
                result = dg( line );
                if( result ){
                    string msg = "Error: delegate fail during loop over stream";
                    logMessage( msg );
                    throw new Exception( msg );
                }
            }
        }

        /**
         * write
         * Put a string to write
         * Examples:
         * Condiuit output = new Conduit( StreamType.Stdout );
         * output.write( "hi, how are you?\n");
         */
        void write(string message){
            int err = FCGX_PutStr( message.toStringz, cast(int)message.length, _request.streamOut );
            if( err == -1 ){
                int code    = FCGX_GetError( _request.streamOut );
                string msg  = "Error %d: during write string".format( code );
                logMessage( msg );
                throw new StreamException( msg );
            }
        }

        /**
         * writef
         * Put any data to write
         * Examples:
         * Condiuit output = new Conduit( StreamType.Stdout );
         * output.write( "hi, i am %d years old", 17);
         */
        void writef(T...)( T messages ){
            foreach( message; messages ){
                Variant variant = message;
                int err = FCGX_FPrintF(  _request.streamOut, variant.get!(string).toStringz );
                if( err == -1 ){
                    int code = FCGX_GetError( _request.streamOut );
                    string msg  = "Error %d: during write formatted string".format( code );
                    logMessage( msg );
                    throw new StreamException( msg );
                }
            }
        }

        void finish(){
            FCGX_Finish_r( &_request );
        }

        @property bool isFinished(){
            return _connection.listenSocket < 0;
        }

        @property Role role(){
            return cast(Role) _request.role;
        }
        /**
         * The root directory of your server
         */
        @property string DOCUMENT_ROOT(){
            return to!string( FCGX_GetParam( "DOCUMENT_ROOT".toStringz, _request.envp ) );
        }

        /**
         * The visitor's cookie, if one is set
         */
        @property string HTTP_COOKIE(){
            return to!string( FCGX_GetParam( "HTTP_COOKIE".toStringz, _request.envp ) );
        }

        /**
         * The hostname of your server
         */
        @property string HTTP_HOST(){
            return to!string( FCGX_GetParam( "HTTP_HOST".toStringz, _request.envp ) );
        }

        /**
         * The URL of the page that called your script
         */
        @property string HTTP_REFERER(){
            return to!string( FCGX_GetParam( "HTTP_REFERER".toStringz, _request.envp ) );
        }

        /**
         * The browser type of the visitor
         */
        @property string HTTP_USER_AGENT(){
            return to!string( FCGX_GetParam( "HTTP_USER_AGENT".toStringz, _request.envp ) );
        }

        /**
         * "on" if the script is being called through a secure server
         */
        @property string HTTPS(){
            return to!string( FCGX_GetParam( "HTTPS".toStringz, _request.envp ) );
        }

        /**
         * The system path your server is running under
         */
        @property string PATH(){
            return to!string( FCGX_GetParam( "PATH".toStringz, _request.envp ) );
        }

        /**
         * The query string (see GET, below)
         */
        @property string QUERY_STRING(){
            return to!string( FCGX_GetParam( "QUERY_STRING".toStringz, _request.envp ) );
        }

        /**
         * The IP address of the visitor
         */
        @property string REMOTE_ADDR(){
            return to!string( FCGX_GetParam( "REMOTE_ADDR".toStringz, _request.envp ) );
        }

        /**
         * The hostname of the visitor (if your server has reverse-name-lookups on; otherwise this is the IP address again)
         */
        @property string REMOTE_HOST(){
            return to!string( FCGX_GetParam( "REMOTE_HOST".toStringz, _request.envp ) );
        }

        /**
         * The port the visitor is connected to on the web server
         */
        @property string REMOTE_PORT(){
            return to!string( FCGX_GetParam( "REMOTE_PORT".toStringz, _request.envp ) );
        }

        /**
         * The visitor's username (for .htaccess-protected pages)
         */
        @property string REMOTE_USER(){
            return to!string( FCGX_GetParam( "REMOTE_USER".toStringz, _request.envp ) );
        }

        /**
         * GET or POST
         */
        @property string REQUEST_METHOD(){
            return to!string( FCGX_GetParam( "REQUEST_METHOD".toStringz, _request.envp ) );
        }

        /**
         * The interpreted pathname of the requested document or CGI (relative to the document root)
         */
        @property string REQUEST_URI(){
            return to!string( FCGX_GetParam( "REQUEST_URI".toStringz, _request.envp ) );
        }

        /**
         * The full pathname of the current CGI
         */
        @property string SCRIPT_FILENAME(){
            return to!string( FCGX_GetParam( "SCRIPT_FILENAME".toStringz, _request.envp ) );
        }

        /**
         * The interpreted pathname of the current CGI (relative to the document root)
         */
        @property string SCRIPT_NAME(){
            return to!string( FCGX_GetParam( "SCRIPT_NAME".toStringz, _request.envp ) );
        }

        /**
         * The email address for your server's webmaster
         */
        @property string SERVER_ADMIN(){
            return to!string( FCGX_GetParam( "SERVER_ADMIN".toStringz, _request.envp ) );
        }

        /**
         * Your server's fully qualified domain name (e.g. www.cgi101.com)
         */
        @property string SERVER_NAME(){
            return to!string( FCGX_GetParam( "SERVER_NAME".toStringz, _request.envp ) );
        }

        /**
         * The port number your server is listening on
         */
        @property string SERVER_PORT(){
            return to!string( FCGX_GetParam( "SERVER_PORT".toStringz, _request.envp ) );
        }

        /**
         * The server software you're using (such as Apache 1.3)
         */
        @property string SERVER_SOFTWARE(){
            return to!string( FCGX_GetParam( "SERVER_SOFTWARE".toStringz, _request.envp ) );
        }

}

enum Role   : ubyte{
    RESPONDER   = FCGI_RESPONDER,
    AUTHORIZER  = FCGI_AUTHORIZER,
    FILTER      = FCGI_FILTER
}


