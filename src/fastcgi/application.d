module fastcgi.application;

import std.parallelism  : totalCPUs, TaskPool, task;
import std.cpuid        : threadsPerCPU;

import fastcgi.request;
import fastcgi.connection;


class Application{
    private:
        TaskPool        _taskPool;
        Connection      _connection;

    public:
        this( Connection connection, void function(Request)[] handlers... ){
            _connection = connection;
            _taskPool   = new TaskPool( totalCPUs * threadsPerCPU + 1);
            add( handlers );
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

        void add( void function(Request)[] handlers... ){
            foreach( handler; handlers ){
                auto t = task!webPage( this, handler);
                _taskPool.put( t );
            }
        }

        @property Connection connection(){
            return _connection;
        }

    static:
        void webPage( void function(Request) handler ){
            Application app         = new Application();
            Request request         = new Request( app.connection );
            while( request.accept() ){
                handler( request );
            }

        }

        void webPage( Application app, void function(Request) handler ){
            Request  request    = new Request( app.connection );
            while( request.accept() ){
                handler( request );
            }
        }


}
