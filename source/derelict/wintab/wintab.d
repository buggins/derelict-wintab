/**
    Derelict binding of WinTab (Wacom Tablet) API.
*/
module derelict.wintab.wintab;

version (Windows):

import core.sys.windows.windows;

private {
    import derelict.util.loader;
    import derelict.util.system;
    import derelict.util.exception;

    static if(Derelict_OS_Windows)
        enum libNames = "wintab32.dll";
    else
        static assert(0, "Wintab is supported only on Windows platform.");
}

alias FIX32 = uint;
alias WTPKT = uint;
alias HCTX = void *;
alias HMGR = void *;

enum : ushort {
    WT_PACKET = 0x7FF0,
    WT_CTXOPEN,
    WT_CTXCLOSE,
    WT_CTXUPDATE,
    WT_CTXOVERLAP,
    WT_PROXIMITY,
    WT_INFOCHANGE,
    WT_CSRCHANGE,
    WT_PACKETEXT,
    WT_MAX,
}


struct AXIS {
    int axMin;
    int axMax;
    uint    axUnits;
    FIX32   axResolution;
}

enum WTI_INTERFACE		= 1;

enum {
    IFC_WINTABID			=1,
    IFC_SPECVERSION		=2,
    IFC_IMPLVERSION		=3,
    IFC_NDEVICES			=4,
    IFC_NCURSORS			=5,
    IFC_NCONTEXTS		=6,
    IFC_CTXOPTIONS		=7,
    IFC_CTXSAVESIZE		=8,
    IFC_NEXTENSIONS		=9,
    IFC_NMANAGERS		=10,
    IFC_MAX				=10,
}

enum WTI_DEVICES = 100;
enum {
    DVC_NAME = 1,
    DVC_HARDWARE = 2,
    DVC_NCSRTYPES = 3,
    DVC_FIRSTCSR = 4,
    DVC_PKTRATE = 5,
    DVC_PKTDATA = 6,
    DVC_PKTMODE = 7,
    DVC_CSRDATA = 8,
    DVC_XMARGIN = 9,
    DVC_YMARGIN = 10,
    DVC_ZMARGIN = 11,
    DVC_X = 12,
    DVC_Y = 13,
    DVC_Z = 14,
    DVC_NPRESSURE = 15,
    DVC_TPRESSURE = 16,
    DVC_ORIENTATION = 17,
    DVC_ROTATION = 18, /* 1.1 */
    DVC_PNPID = 19, /* 1.1 */
    DVC_MAX = 19,
}

enum WTI_DEFCONTEXT	= 3;
enum WTI_DEFSYSCTX	= 4;
enum WTI_DDCTXS		=400; /* 1.1 */
enum WTI_DSCTXS		=500; /* 1.1 */
enum {
    CTX_NAME			=1,
    CTX_OPTIONS		=2,
    CTX_STATUS		=3,
    CTX_LOCKS			=4,
    CTX_MSGBASE		=5,
    CTX_DEVICE		=6,
    CTX_PKTRATE		=7,
    CTX_PKTDATA		=8,
    CTX_PKTMODE		=9,
    CTX_MOVEMASK		=10,
    CTX_BTNDNMASK	=11,
    CTX_BTNUPMASK	=12,
    CTX_INORGX		=13,
    CTX_INORGY		=14,
    CTX_INORGZ		=15,
    CTX_INEXTX		=16,
    CTX_INEXTY		=17,
    CTX_INEXTZ		=18,
    CTX_OUTORGX		=19,
    CTX_OUTORGY		=20,
    CTX_OUTORGZ		=21,
    CTX_OUTEXTX		=22,
    CTX_OUTEXTY		=23,
    CTX_OUTEXTZ		=24,
    CTX_SENSX			=25,
    CTX_SENSY			=26,
    CTX_SENSZ			=27,
    CTX_SYSMODE		=28,
    CTX_SYSORGX		=29,
    CTX_SYSORGY		=30,
    CTX_SYSEXTX		=31,
    CTX_SYSEXTY		=32,
    CTX_SYSSENSX		=33,
    CTX_SYSSENSY		=34,
    CTX_MAX			=34,
}

/* WTPKT bits */
enum : uint {
    PK_CONTEXT				=0x0001,	/* reporting context */
    PK_STATUS					=0x0002,	/* status bits */
    PK_TIME					=0x0004,	/* time stamp */
    PK_CHANGED				=0x0008,	/* change bit vector */
    PK_SERIAL_NUMBER		=0x0010,	/* packet serial number */
    PK_CURSOR					=0x0020,	/* reporting cursor */
    PK_BUTTONS				=0x0040,	/* button information */
    PK_X						=0x0080,	/* x axis */
    PK_Y						=0x0100,	/* y axis */
    PK_Z						=0x0200,	/* z axis */
    PK_NORMAL_PRESSURE		=0x0400,	/* normal or tip pressure */
    PK_TANGENT_PRESSURE	=0x0800,	/* tangential or barrel pressure */
    PK_ORIENTATION			=0x1000,	/* orientation info: tilts */
    PK_ROTATION				=0x2000,	/* rotation info; 1.1 */
}

immutable uint PK_ALL = PK_CONTEXT | PK_STATUS | PK_TIME | PK_CHANGED
                    | PK_SERIAL_NUMBER | PK_CURSOR | PK_BUTTONS | PK_X | PK_Y | PK_Z 
                    | PK_NORMAL_PRESSURE | PK_TANGENT_PRESSURE | PK_ORIENTATION | PK_ROTATION;

enum LCNAMELEN = 40;
struct LOGCONTEXT {
    /// Contains a zero-terminated context name string.
	wchar[LCNAMELEN] lcName; 
    /**
        Specifies options for the context. These options can be com­bined by using the bitwise OR operator. 
        The lcOptions field can be any combination of the values defined in table 7.11. 
        Specify­ing options that are unsupported in a particular im­plementation will cause WTOpen to fail.
    */
	uint	lcOptions;
    /**
        Specifies current status conditions for the context. These condi­tions can be combined by using the bitwise OR opera­tor. 
        The lcStatus field can be any combination of the values defined in table 7.12.
    */
	uint	lcStatus;
    /**
        Specifies which attributes of the context the application wishes to be locked. 
        Lock conditions specify attributes of the context that cannot be changed once the context has been opened 
        (calls to WTConfig will have no effect on the locked attributes). 
        The lock conditions can be combined by using the bitwise OR opera­tor. 
        The lcLocks field can be any combina­tion of the values de­fined in table 7.13. 
        Locks can only be changed by the task or process that owns the context.
    */
	uint	lcLocks;
    /** Specifies the range of message numbers that will be used for re­porting the activity of the context. See the message descrip­tions in section 6.
    */
	uint	lcMsgBase;
    /** Specifies the device whose input the context processes. */
	uint	lcDevice;
    /** Specifies the desired packet report rate in Hertz. Once the con­text is opened, this field will contain the actual report rate. */
	uint	lcPktRate;
    /** Specifies which optional data items will be in packets re­turned from the context. Requesting unsupported data items will cause WTOpen to fail. */
	WTPKT	lcPktData;
    /** Specifies whether the packet data items will be returned in abso­lute or relative mode. If the item's bit is set in this field, the item will be returned in relative mode. Bits in this field for items not selected in the lcPktData field will be ignored. Bits for data items that only allow one mode (such as the serial number) will also be ignored. */
	WTPKT	lcPktMode;
    /** Specifies which packet data items can generate move events in the context. Bits for items that are not part of the packet def­ini­tion in the lcPktData field will be ignored. The bits for but­tons, time stamp, and the serial number will also be ig­nored. In the case of overlapping contexts, movement events for data items not selected in this field may be processed by underlying con­texts. */
	WTPKT	lcMoveMask;
    /** Specifies the buttons for which button press events will be proc­essed in the context. 
        In the case of overlapping contexts, button press events for buttons that are not selected in this 
        field may be processed by underlying contexts. */
	uint	lcBtnDnMask;
    /** Specifies the buttons for which button release events will be processed in the context. 
        In the case of overlapping contexts, button release events for buttons that are not selected in this field may be processed by underlying contexts.
        If both press and re­lease events are selected for a button (see the lcBtnDnMask field above), 
        then the interface will cause the context to implic­itly capture all tablet events while the button is down. In this case, events occurring outside the context will be clipped to the context and processed as if they had occurred in the context. When the but­ton is released, 
        the context will receive the button release event, and then event processing will return to normal. */
	uint	lcBtnUpMask;
    /** Each specifies the origin of the context's input area in the tab­let's native coordinates, along the x, y, and z axes, respec­tively. 
        Each will be clipped to the tablet native coordinate space when the context is opened or modified. */
	int	lcInOrgX;
	int	lcInOrgY;
	int	lcInOrgZ;
    /** Each specifies the extent of the context's input area in the tab­let's native coordinates, along the x, y, and z axes, respec­tively. 
        Each will be clipped to the tablet native coordinate space when the context is opened or modified. */
	int	lcInExtX;
	int	lcInExtY;
	int	lcInExtZ;
    /** Each specifies the origin of the context's output area in con­text output coordinates, along the x, y, and z axes, respec­tively. 
        Each is used in coordinate scaling for absolute mode only. */
	int	lcOutOrgX;
	int	lcOutOrgY;
	int	lcOutOrgZ;
    /** Each specifies the extent of the context's output area in con­text output coordinates, along the x, y, and z axes, respec­tively. 
        Each is used in coordinate scaling for absolute mode only. */
	int	lcOutExtX;
	int	lcOutExtY;
	int	lcOutExtZ;
    /** Each specifies the relative-mode sensitivity factor for the x, y, and z axes, respectively. */
	FIX32	lcSensX;
	FIX32	lcSensY;
	FIX32	lcSensZ;
	int	lcSysMode; // BOOL
	int	lcSysOrgX;
	int	lcSysOrgY;
	int	lcSysExtX;
	int	lcSysExtY;
	FIX32	lcSysSensX;
	FIX32	lcSysSensY;
}

/* context option values */
enum {
    CXO_SYSTEM		=0x0001,
    CXO_PEN			=0x0002,
    CXO_MESSAGES		=0x0004,
    CXO_MARGIN		=0x8000,
    CXO_MGNINSIDE	=0x4000,
    CXO_CSRMESSAGES	=0x0008, /* 1.1 */
}

/* context status values */
enum {
    CXS_DISABLED		=0x0001,
    CXS_OBSCURED		=0x0002,
    CXS_ONTOP			=0x0004,
}

/* context lock values */
enum {
    CXL_INSIZE		=0x0001,
    CXL_INASPECT		=0x0002,
    CXL_SENSITIVITY	=0x0004,
    CXL_MARGIN		=0x0008,
    CXL_SYSOUT		=0x0010,
}

/* -------------------------------------------------------------------------- */
/* EVENT DATA DEFS */

/* For packet structure definition, see pktdef.h */

/* packet status values */
enum {
    TPS_PROXIMITY		=0x0001,
    TPS_QUEUE_ERR		=0x0002,
    TPS_MARGIN			=0x0004,
    TPS_GRAB				=0x0008,
    TPS_INVERT			=0x0010, /* 1.1 */
}

struct ORIENTATION {
	int orAzimuth;
	int orAltitude;
	int orTwist;
}

struct ROTATION { /* 1.1 */
	int roPitch;
	int roRoll;
	int roYaw;
}

/* relative buttons */
enum {
    TBN_NONE	= 0,
    TBN_UP		=1,
    TBN_DOWN	=2
}

/* DEVICE CONFIG CONSTANTS */
enum {
    WTDC_NONE		=0,
    WTDC_CANCEL		=1,
    WTDC_OK			=2,
    WTDC_RESTART	=3,
}


/**
   PACKET struct template. Pass PK_XXX bit mask to select which fields to instantiate.
*/
struct PACKET (uint fields = PK_ALL) {
    static immutable uint PACKETDATA = fields;
    static if (fields & PK_CONTEXT) 
        HCTX pkContext;
    static if (fields & PK_STATUS) 
        uint        pkStatus;
    static if (fields & PK_TIME) 
        int         pkTime;
    static if (fields & PK_CHANGED) 
        WTPKT       pkChanged;
    static if (fields & PK_SERIAL_NUMBER) 
        uint        pkSerialNumber;
    static if (fields & PK_CURSOR) 
        uint        pkCursor;
    static if (fields & PK_BUTTONS) 
        uint        pkButtons;
    static if (fields & PK_X)
        uint        pkX;
    static if (fields & PK_Y)
        uint        pkY;
    static if (fields & PK_Z)
        uint        pkZ;
    static if (fields & PK_NORMAL_PRESSURE)
        uint        pkNormalPressure;
    static if (fields & PK_TANGENT_PRESSURE)
        uint        pkTangentPressure;
    static if (fields & PK_ORIENTATION)
        ORIENTATION pkOrientation;
    static if (fields & PK_ROTATION)
        ROTATION    pkRotation;  /* 1.1 */
}

extern(Windows) @nogc nothrow {
    /** This function returns global information about the interface in an application-sup­plied buffer. 
       Different types of information are specified by different index argu­ments. Applications use this function to receive information about tablet coordi­nates, physical dimensions, capabilities, and cursor types.
       Parameters:
            wCategory : UINT  Identifies the category from which information is being re­quested.
            nIndex : UINT  Identifies which information is being requested from within the category.
            lpOutput : LPVOID  Points to a buffer to hold the requested information. 
       Returns:
            The return value specifies the size of the returned information in bytes. 
            If the infor­mation is not supported, the function returns zero. If a tablet is not physi­cally pres­ent, this function always returns zero.
    */
    alias da_WTInfo = uint function(uint wCategory, uint  nIndex, void* lpOutput);
    alias da_WTOpen = HCTX function (HWND hWnd, LOGCONTEXT * lpLogCtx, BOOL fEnable);
    alias da_WTGet = int function (HCTX hCtx, LOGCONTEXT * lpLogCtx);
    alias da_WTSet = int function (HCTX, LOGCONTEXT * lpLogCtx);
    alias da_WTClose = int function (HCTX hCtx);
    alias da_WTEnable = int function (HCTX hCtx, BOOL fEnable);
    alias da_WTPacket = int function (HCTX hCtx, uint wSerial, void * lpPkt);
    alias da_WTOverlap = int function (HCTX hCtx, BOOL fToTop);
    alias da_WTSave = int function (HCTX hCtx, void * );
    alias da_WTConfig = int function (HCTX hCtx, HWND hWnd);
    alias da_WTRestore = HCTX function (HWND hWnd, void *, int );
    alias da_WTExtSet = int function (HCTX hCtx, uint, void * );
    alias da_WTExtGet = int function (HCTX hCtx, uint, void * );
    alias da_WTQueueSizeSet = int function (HCTX hCtx, int );
    alias da_WTDataPeek =  int function (HCTX hCtx, uint, uint, int, void *, int*);
    alias da_WTPacketsGet = int function (HCTX hCtx, int, void *);
    alias da_WTMgrOpen = HMGR function (HWND hWnd, uint );
    alias da_WTMgrClose = int function (HMGR hMgr);
    alias da_WTMgrDefContext = HCTX function (HMGR hMgr, int );
    alias da_WTMgrDefContextEx = HCTX function (HMGR hMgr, uint, int );
}

__gshared {
    da_WTInfo WTInfo;
    da_WTOpen WTOpen;
    da_WTGet WTGet;
    da_WTSet WTSet;
    da_WTClose WTClose;
    da_WTEnable WTEnable;
    da_WTPacket WTPacket;
    da_WTOverlap WTOverlap;
    da_WTSave WTSave;
    da_WTConfig WTConfig;
    da_WTRestore WTRestore;
    da_WTExtSet WTExtSet;
    da_WTExtGet WTExtGet;
    da_WTQueueSizeSet WTQueueSizeSet;
    da_WTDataPeek WTDataPeek;
    da_WTPacketsGet WTPacketsGet;
    da_WTMgrOpen WTMgrOpen;
    da_WTMgrClose WTMgrClose;
    da_WTMgrDefContext WTMgrDefContext;
    da_WTMgrDefContextEx WTMgrDefContextEx;
}

class DerelictWintabLoader : SharedLibLoader {
    public this() {
        super(libNames);
    }

    protected override void loadSymbols()
    {
        bindFunc(cast(void**)&WTInfo, "WTInfoW");
        bindFunc(cast(void**)&WTOpen, "WTOpenW");
        bindFunc(cast(void**)&WTGet, "WTGetW");
        bindFunc(cast(void**)&WTSet, "WTSetW");
        bindFunc(cast(void**)&WTClose, "WTClose");
        bindFunc(cast(void**)&WTEnable, "WTEnable");
        bindFunc(cast(void**)&WTPacket, "WTPacket");
        bindFunc(cast(void**)&WTOverlap, "WTOverlap");
        bindFunc(cast(void**)&WTSave, "WTSave");
        bindFunc(cast(void**)&WTConfig, "WTConfig");
        bindFunc(cast(void**)&WTRestore, "WTRestore");
        bindFunc(cast(void**)&WTExtSet, "WTExtSet");
        bindFunc(cast(void**)&WTExtGet, "WTExtGet");
        bindFunc(cast(void**)&WTQueueSizeSet, "WTQueueSizeSet");
        bindFunc(cast(void**)&WTDataPeek, "WTDataPeek");
        bindFunc(cast(void**)&WTPacketsGet, "WTPacketsGet");
        bindFunc(cast(void**)&WTMgrOpen, "WTMgrOpen");
        bindFunc(cast(void**)&WTMgrClose, "WTMgrClose");
        bindFunc(cast(void**)&WTMgrDefContext, "WTMgrDefContext");
        bindFunc(cast(void**)&WTMgrDefContextEx, "WTMgrDefContextEx");
    }
}


__gshared DerelictWintabLoader DerelictWintab;

shared static this() {
    DerelictWintab = new DerelictWintabLoader();
}
