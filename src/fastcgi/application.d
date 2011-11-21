module fastcgi.application;

import std.parallelism  : totalCPUs, TaskPool, task;
import std.cpuid        : threadsPerCPU;

import fastcgi.request;
import fastcgi.connection;

void webPage( void function(Request) handler ){
    Connection connection   = new Connection();
    Request request         = new Request( connection );
    while( request.accept() ){
        handler( request );
    }

}

void webPage( Connection connection, void function(Request) handler ){
    Request  request    = new Request( connection );
    while( request.accept() ){
        handler( request );
    }
}

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
                auto t = task!webPage( _connection, handler);
                _taskPool.put( t );
            }
        }


}
