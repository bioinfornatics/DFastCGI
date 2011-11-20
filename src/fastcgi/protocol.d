module fastcgi.protocol;

import fastcgi.c.fastcgi;


enum State      : ubyte{
    RequestComplete             = FCGI_REQUEST_COMPLETE,
    CannotMultiplexConnection   = FCGI_CANT_MPX_CONN,
    Overloaded                  = FCGI_OVERLOADED,
    UnknownRole                 = FCGI_UNKNOWN_ROLE
}


enum Flag       : ubyte{
    NoFlag                      = 0,
    KeepAlive                   = FCGI_KEEP_CONN
}

enum StreamType : ubyte{
    NoStream                    = 0,
    Stdin                       = FCGI_STDIN,
    Stdout                      = FCGI_STDOUT,
    Stderr                      = FCGI_STDERR,
    Data                        = FCGI_DATA
}

enum RecordType : ubyte{
    BeginRequest                = FCGI_BEGIN_REQUEST,
    AbortRequest                = FCGI_ABORT_REQUEST,
    EndRequest                  = FCGI_END_REQUEST,
    Params                      = FCGI_PARAMS,
    Stdin                       = FCGI_STDIN,
    Stdout                      = FCGI_STDOUT,
    Stderr                      = FCGI_STDERR,
    Data                        = FCGI_DATA,
    GetValues                   = FCGI_GET_VALUES,
    GetValuesResult             = FCGI_GET_VALUES_RESULT,
    UnknownRecordType           = FCGI_UNKNOWN_TYPE
}
