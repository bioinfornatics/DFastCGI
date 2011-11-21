module fastcgi.connection;

import std.string;
import std.process;
import std.conv;

import fastcgi.exception;
import fastcgi.c.fastcgi : FCGI_LISTENSOCK_FILENO;
import fastcgi.c.fcgiapp;

class Connection{
    private:
        int             _listenSocket;
        int             _backlog;
        string[]        _validAddress;
        string          _socketPath;

        void init( string socketPath = null, int backlog = 0  ){
            string adress   = to!string( getenv( "FCGI_WEB_SERVER_ADDRS" ) );
            _validAddress   = ( adress == "0" ) ? null : adress.split(",");
            _socketPath     = socketPath;
            _backlog        = backlog;
            int err         = FCGX_Init(); // call before Accept in multithreaded apps
            if( err != 0 )
                throw new ConnectionException( "Conection initialization failled" );
            if( socketPath !is null ){
                _listenSocket = FCGX_OpenSocket( _socketPath.toStringz, backlog );
                if( _listenSocket == -1 )
                    throw new ConnectionException( "Opening socket failled" );
            }
            else
                _listenSocket = FCGI_LISTENSOCK_FILENO;
        }
    public:
        this( string socketPath, size_t port, int backlog = 0 ){
            init( socketPath ~ ":" ~ to!string( port ), backlog );
        }

        this( string socketPath, int backlog = 0 ){
            init( _socketPath, backlog );
        }

        this( ){
            init( );
        }

        this( int listenSocket, string[] validAddress, string socketPath ){
            _listenSocket   = listenSocket;
            _validAddress   = validAddress;
            _socketPath     = socketPath;
            init( _socketPath, _backlog );
        }

        ~this(){
            finnish();
        }

        Connection dup(){
            return new Connection( _listenSocket,  _validAddress, _socketPath );
        }

        /**
         * isCGI
         * Returns true if this process appears to be a CGI process
         * rather than a FastCGI process.
         */
        bool isCGI(){
            return ( FCGX_IsCGI() == 1 ) ? true : false;
        }

        /**
         * listenSocket
         * Returns number from listen socket
         */
        @property int listenSocket(){
            return _listenSocket;
        }

        /**
         * accept
         * Returns number from listen socket
         * same as listenSocket method
         */
        @property int accept(){
            return _listenSocket;
        }

        @property void finnish(){
            _listenSocket = -1;
        }

        /**
         * validAddress
         * Returns web server adress
         */
        @property string[] validAddress(){
            return _validAddress.dup;
        }

        /**
         * socketPath
         * Returns path to socket ( could be null )
         */
        @property string socketPath(){
            return _socketPath.idup;
        }

}
