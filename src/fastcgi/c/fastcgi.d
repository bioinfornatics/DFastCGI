module fastcgi.c.fastcgi;

extern (System) {
/*
 * Listening socket file number
 */
const(int) FCGI_LISTENSOCK_FILENO =   0;

struct FCGI_Header{
    ubyte FCGI_version;
    ubyte type;
    ubyte requestIdB1;
    ubyte requestIdB0;
    ubyte contentLengthB1;
    ubyte contentLengthB0;
    ubyte paddingLength;
    ubyte reserved;
}

const(int) FCGI_MAX_LENGTH =   0xffff ;

/*
 * Number of bytes in a FCGI_Header.  Future versions of the protocol
 * will not reduce this number.
 */
const(int) FCGI_HEADER_LEN        =    8;

/*
 * Value for version component of FCGI_Header
 */
const(int) FCGI_VERSION_1         =     1;

/*
 * Values for type component of FCGI_Header
 */
const(int) FCGI_BEGIN_REQUEST     =     1;
const(int) FCGI_ABORT_REQUEST     =     2;
const(int) FCGI_END_REQUEST       =     3;
const(int) FCGI_PARAMS            =     4;
const(int) FCGI_STDIN             =     5;
const(int) FCGI_STDOUT            =     6;
const(int) FCGI_STDERR            =     7;
const(int) FCGI_DATA              =     8;
const(int) FCGI_GET_VALUES        =     9;
const(int) FCGI_GET_VALUES_RESULT =    10;
const(int) FCGI_UNKNOWN_TYPE      =    11;
const(int) FCGI_MAXTYPE           =    FCGI_UNKNOWN_TYPE;

/*
 * Value for requestId component of FCGI_Header
 */
const(int) FCGI_NULL_REQUEST_ID =       0;


struct FCGI_BeginRequestBody {
    ubyte roleB1;
    ubyte roleB0;
    ubyte flags;
    ubyte reserved[5];
}

struct FCGI_BeginRequestRecord {
    FCGI_Header             headerHtml;
    FCGI_BeginRequestBody   bodyHtml;
}

/*
 * Mask for flags component of FCGI_BeginRequestBody
 */
const(int) FCGI_KEEP_CONN =    1;

/*
 * Values for role component of FCGI_BeginRequestBody
 */
const(int) FCGI_RESPONDER  =   1;
const(int) FCGI_AUTHORIZER =   2;
const(int) FCGI_FILTER     =   3;


struct FCGI_EndRequestBody {
    ubyte appStatusB3;
    ubyte appStatusB2;
    ubyte appStatusB1;
    ubyte appStatusB0;
    ubyte protocolStatus;
    ubyte reserved[3];
}

struct FCGI_EndRequestRecord {
    FCGI_Header         headerHtml;
    FCGI_EndRequestBody bodyHtml;
}

/*
 * Values for protocolStatus component of FCGI_EndRequestBody
 */
const(int) FCGI_REQUEST_COMPLETE =   0;
const(int) FCGI_CANT_MPX_CONN    =   1;
const(int) FCGI_OVERLOADED       =   2;
const(int) FCGI_UNKNOWN_ROLE     =   3;


/*
 * Variable names for FCGI_GET_VALUES / FCGI_GET_VALUES_RESULT records
 */
const(string) FCGI_MAX_CONNS  = "FCGI_MAX_CONNS";
const(string) FCGI_MAX_REQS   = "FCGI_MAX_REQS";
const(string) FCGI_MPXS_CONNS = "FCGI_MPXS_CONNS";


struct FCGI_UnknownTypeBody {
    ubyte type;
    ubyte reserved[7];
}

struct FCGI_UnknownTypeRecord {
    FCGI_Header             headerHtml;
    FCGI_UnknownTypeBody    bodyHtml;
}

}
