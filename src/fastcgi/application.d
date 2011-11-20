module fastcgi.application;

import std.parallelism  : totalCPUs, TaskPool, task;
import std.cpuid        : threadsPerCPU;

import fastcgi.request;
import fastcgi.connection;

class Page{

    private:
        Connection              _connection;
        Request                 _request;
        bool                    _isRunning;
        void function(Request)  _handler;

    public:

        this( void function(Request) handler ){
            _connection = new Connection();
            _handler    = handler;
            _isRunning  = true;
            _request    = new Request( _connection );
        }

        this( Connection connection, void function(Request) handler ){
            _connection = connection;
            _handler    = handler;
            _isRunning  = true;
            _request    = new Request( _connection );
        }

        ~this(){
            stop();
        }

        void run(){
            while( _isRunning ){
                _handler( _request );
            }
        }

        void stop(){
            _isRunning = false;
        }
}

class Application{
    private:
        TaskPool        _taskPool;
        Connection      _connection;

    public:
        this( Connection connection, Page pages... ){
            _connection = connection;
            _taskPool   = new TaskPool( totalCPUs * threadsPerCPU + 1);
            addPages( pages );
        }

        this( Connection connection = null ){
            if( connection is null )
                _connection = new Connection();
            else
                _connection = connection;
            _taskPool   = new TaskPool( totalCPUs * threadsPerCPU + 1);
        }

        ~this(){
            _taskPool.finish();
        }

        void addPages( Page pages... ){
            foreach( Page page; pages ){
                auto t = task!page.run();
                _taskPool.put( t );
            }
        }

        void add( void function(Request) handlers... ){
            foreach( handler; handlers ){
                Page page = new Page( _connection, handler );
                auto t = task!page.run();
                _taskPool.put( t );
            }
        }


}
