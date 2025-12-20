/*
 * WebView2Helper.c - Native COM callback helper for AutoIt WebView2 UDF
 * Author: Ralle1976
 *
 * This DLL provides proper COM callback implementations for WebView2
 * and communicates back to AutoIt via Windows messages.
 *
 * Compile with: cl /LD /MD WebView2Helper.c /Fe:WebView2Helper.dll ole32.lib
 */

#define WIN32_LEAN_AND_MEAN
#define COBJMACROS
#include <windows.h>
#include <objbase.h>
#include <stdlib.h>

/* WebView2 interface GUIDs */
static const GUID IID_ICoreWebView2Environment =
    {0xb96d755e, 0x0319, 0x4e92, {0xa2, 0x96, 0x23, 0x43, 0x6f, 0x46, 0xa1, 0xfc}};

static const GUID IID_ICoreWebView2Controller =
    {0x4d00c0d1, 0x9434, 0x4eb6, {0x80, 0x78, 0x86, 0x97, 0xa5, 0x60, 0x33, 0x4f}};

static const GUID IID_ICoreWebView2 =
    {0x76eceacb, 0x0462, 0x4d94, {0xac, 0x83, 0x42, 0x3a, 0x67, 0x93, 0x77, 0x5e}};

/* Window message IDs for AutoIt communication */
#define WM_WV2_ENVIRONMENT_CREATED  (WM_USER + 100)
#define WM_WV2_CONTROLLER_CREATED   (WM_USER + 101)
#define WM_WV2_NAVIGATION_COMPLETED (WM_USER + 102)
#define WM_WV2_WEB_MESSAGE_RECEIVED (WM_USER + 103)
#define WM_WV2_SCRIPT_COMPLETED     (WM_USER + 104)

/* Global state */
static HWND g_hNotifyWnd = NULL;
static void* g_pEnvironment = NULL;
static void* g_pController = NULL;
static void* g_pWebView2 = NULL;
static CRITICAL_SECTION g_cs;
static BOOL g_bInitialized = FALSE;

/* Forward declarations */
typedef struct EnvironmentHandler EnvironmentHandler;
typedef struct ControllerHandler ControllerHandler;
typedef struct NavigationHandler NavigationHandler;
typedef struct WebMessageHandler WebMessageHandler;
typedef struct ScriptHandler ScriptHandler;

/* ============================================================================
 * ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler Implementation
 * ============================================================================ */

typedef HRESULT (__stdcall *PFNENVINVOKE)(void* pHandler, HRESULT result, void* pEnv);

typedef struct EnvironmentHandler {
    void** lpVtbl;
    LONG refCount;
    HWND hNotifyWnd;
} EnvironmentHandler;

static HRESULT __stdcall EnvHandler_QueryInterface(EnvironmentHandler* pThis, REFIID riid, void** ppvObject) {
    if (IsEqualGUID(riid, &IID_IUnknown)) {
        *ppvObject = pThis;
        pThis->refCount++;
        return S_OK;
    }
    *ppvObject = NULL;
    return E_NOINTERFACE;
}

static ULONG __stdcall EnvHandler_AddRef(EnvironmentHandler* pThis) {
    return InterlockedIncrement(&pThis->refCount);
}

static ULONG __stdcall EnvHandler_Release(EnvironmentHandler* pThis) {
    LONG ref = InterlockedDecrement(&pThis->refCount);
    if (ref == 0) {
        free(pThis->lpVtbl);
        free(pThis);
    }
    return ref;
}

static HRESULT __stdcall EnvHandler_Invoke(EnvironmentHandler* pThis, HRESULT result, void* pEnvironment) {
    EnterCriticalSection(&g_cs);

    if (SUCCEEDED(result) && pEnvironment != NULL) {
        g_pEnvironment = pEnvironment;
        /* AddRef to keep the environment alive */
        ((ULONG (__stdcall *)(void*))(*((void***)pEnvironment))[1])(pEnvironment);
    }

    LeaveCriticalSection(&g_cs);

    /* Notify AutoIt */
    if (pThis->hNotifyWnd) {
        PostMessage(pThis->hNotifyWnd, WM_WV2_ENVIRONMENT_CREATED, (WPARAM)result, (LPARAM)pEnvironment);
    }

    return S_OK;
}

/* VTable for EnvironmentHandler */
static void* EnvHandler_VTable[] = {
    EnvHandler_QueryInterface,
    EnvHandler_AddRef,
    EnvHandler_Release,
    EnvHandler_Invoke
};

/* ============================================================================
 * ICoreWebView2CreateCoreWebView2ControllerCompletedHandler Implementation
 * ============================================================================ */

typedef struct ControllerHandler {
    void** lpVtbl;
    LONG refCount;
    HWND hNotifyWnd;
} ControllerHandler;

static HRESULT __stdcall CtrlHandler_QueryInterface(ControllerHandler* pThis, REFIID riid, void** ppvObject) {
    if (IsEqualGUID(riid, &IID_IUnknown)) {
        *ppvObject = pThis;
        pThis->refCount++;
        return S_OK;
    }
    *ppvObject = NULL;
    return E_NOINTERFACE;
}

static ULONG __stdcall CtrlHandler_AddRef(ControllerHandler* pThis) {
    return InterlockedIncrement(&pThis->refCount);
}

static ULONG __stdcall CtrlHandler_Release(ControllerHandler* pThis) {
    LONG ref = InterlockedDecrement(&pThis->refCount);
    if (ref == 0) {
        free(pThis->lpVtbl);
        free(pThis);
    }
    return ref;
}

static HRESULT __stdcall CtrlHandler_Invoke(ControllerHandler* pThis, HRESULT result, void* pController) {
    EnterCriticalSection(&g_cs);

    if (SUCCEEDED(result) && pController != NULL) {
        g_pController = pController;
        /* AddRef to keep the controller alive */
        ((ULONG (__stdcall *)(void*))(*((void***)pController))[1])(pController);

        /* Get ICoreWebView2 from controller */
        /* get_CoreWebView2 is at VTable index 25 */
        void*** pCtrlVT = (void***)pController;
        HRESULT hr = ((HRESULT (__stdcall *)(void*, void**))(*pCtrlVT)[25])(pController, &g_pWebView2);
        if (SUCCEEDED(hr) && g_pWebView2 != NULL) {
            /* AddRef the WebView2 */
            ((ULONG (__stdcall *)(void*))(*((void***)g_pWebView2))[1])(g_pWebView2);
        }
    }

    LeaveCriticalSection(&g_cs);

    /* Notify AutoIt */
    if (pThis->hNotifyWnd) {
        PostMessage(pThis->hNotifyWnd, WM_WV2_CONTROLLER_CREATED, (WPARAM)result, (LPARAM)pController);
    }

    return S_OK;
}

/* VTable for ControllerHandler */
static void* CtrlHandler_VTable[] = {
    CtrlHandler_QueryInterface,
    CtrlHandler_AddRef,
    CtrlHandler_Release,
    CtrlHandler_Invoke
};

/* ============================================================================
 * ICoreWebView2NavigationCompletedEventHandler Implementation
 * ============================================================================ */

typedef struct NavigationHandler {
    void** lpVtbl;
    LONG refCount;
    HWND hNotifyWnd;
} NavigationHandler;

static HRESULT __stdcall NavHandler_QueryInterface(NavigationHandler* pThis, REFIID riid, void** ppvObject) {
    if (IsEqualGUID(riid, &IID_IUnknown)) {
        *ppvObject = pThis;
        pThis->refCount++;
        return S_OK;
    }
    *ppvObject = NULL;
    return E_NOINTERFACE;
}

static ULONG __stdcall NavHandler_AddRef(NavigationHandler* pThis) {
    return InterlockedIncrement(&pThis->refCount);
}

static ULONG __stdcall NavHandler_Release(NavigationHandler* pThis) {
    LONG ref = InterlockedDecrement(&pThis->refCount);
    if (ref == 0) {
        free(pThis->lpVtbl);
        free(pThis);
    }
    return ref;
}

static HRESULT __stdcall NavHandler_Invoke(NavigationHandler* pThis, void* pSender, void* pArgs) {
    BOOL isSuccess = FALSE;

    if (pArgs != NULL) {
        /* get_IsSuccess is at VTable index 3 */
        void*** pArgsVT = (void***)pArgs;
        ((HRESULT (__stdcall *)(void*, BOOL*))(*pArgsVT)[3])(pArgs, &isSuccess);
    }

    /* Notify AutoIt */
    if (pThis->hNotifyWnd) {
        PostMessage(pThis->hNotifyWnd, WM_WV2_NAVIGATION_COMPLETED, (WPARAM)isSuccess, 0);
    }

    return S_OK;
}

/* VTable for NavigationHandler */
static void* NavHandler_VTable[] = {
    NavHandler_QueryInterface,
    NavHandler_AddRef,
    NavHandler_Release,
    NavHandler_Invoke
};

/* ============================================================================
 * ICoreWebView2WebMessageReceivedEventHandler Implementation
 * ============================================================================ */

/* Shared message buffer for AutoIt */
static WCHAR g_szLastMessage[32768] = {0};

typedef struct WebMessageHandler {
    void** lpVtbl;
    LONG refCount;
    HWND hNotifyWnd;
} WebMessageHandler;

static HRESULT __stdcall MsgHandler_QueryInterface(WebMessageHandler* pThis, REFIID riid, void** ppvObject) {
    if (IsEqualGUID(riid, &IID_IUnknown)) {
        *ppvObject = pThis;
        pThis->refCount++;
        return S_OK;
    }
    *ppvObject = NULL;
    return E_NOINTERFACE;
}

static ULONG __stdcall MsgHandler_AddRef(WebMessageHandler* pThis) {
    return InterlockedIncrement(&pThis->refCount);
}

static ULONG __stdcall MsgHandler_Release(WebMessageHandler* pThis) {
    LONG ref = InterlockedDecrement(&pThis->refCount);
    if (ref == 0) {
        free(pThis->lpVtbl);
        free(pThis);
    }
    return ref;
}

static HRESULT __stdcall MsgHandler_Invoke(WebMessageHandler* pThis, void* pSender, void* pArgs) {
    if (pArgs != NULL) {
        /* TryGetWebMessageAsString is at VTable index 4 */
        void*** pArgsVT = (void***)pArgs;
        LPWSTR pMessage = NULL;
        HRESULT hr = ((HRESULT (__stdcall *)(void*, LPWSTR*))(*pArgsVT)[4])(pArgs, &pMessage);

        if (SUCCEEDED(hr) && pMessage != NULL) {
            EnterCriticalSection(&g_cs);
            wcsncpy_s(g_szLastMessage, 32768, pMessage, _TRUNCATE);
            LeaveCriticalSection(&g_cs);
            CoTaskMemFree(pMessage);
        } else {
            /* Try get_WebMessageAsJson at VTable index 5 */
            hr = ((HRESULT (__stdcall *)(void*, LPWSTR*))(*pArgsVT)[5])(pArgs, &pMessage);
            if (SUCCEEDED(hr) && pMessage != NULL) {
                EnterCriticalSection(&g_cs);
                wcsncpy_s(g_szLastMessage, 32768, pMessage, _TRUNCATE);
                LeaveCriticalSection(&g_cs);
                CoTaskMemFree(pMessage);
            }
        }
    }

    /* Notify AutoIt */
    if (pThis->hNotifyWnd) {
        PostMessage(pThis->hNotifyWnd, WM_WV2_WEB_MESSAGE_RECEIVED, 0, 0);
    }

    return S_OK;
}

/* VTable for WebMessageHandler */
static void* MsgHandler_VTable[] = {
    MsgHandler_QueryInterface,
    MsgHandler_AddRef,
    MsgHandler_Release,
    MsgHandler_Invoke
};

/* ============================================================================
 * ICoreWebView2ExecuteScriptCompletedHandler Implementation
 * ============================================================================ */

static WCHAR g_szScriptResult[65536] = {0};

typedef struct ScriptHandler {
    void** lpVtbl;
    LONG refCount;
    HWND hNotifyWnd;
} ScriptHandler;

static HRESULT __stdcall ScriptHandler_QueryInterface(ScriptHandler* pThis, REFIID riid, void** ppvObject) {
    if (IsEqualGUID(riid, &IID_IUnknown)) {
        *ppvObject = pThis;
        pThis->refCount++;
        return S_OK;
    }
    *ppvObject = NULL;
    return E_NOINTERFACE;
}

static ULONG __stdcall ScriptHandler_AddRef(ScriptHandler* pThis) {
    return InterlockedIncrement(&pThis->refCount);
}

static ULONG __stdcall ScriptHandler_Release(ScriptHandler* pThis) {
    LONG ref = InterlockedDecrement(&pThis->refCount);
    if (ref == 0) {
        free(pThis->lpVtbl);
        free(pThis);
    }
    return ref;
}

static HRESULT __stdcall ScriptHandler_Invoke(ScriptHandler* pThis, HRESULT errorCode, LPCWSTR resultObjectAsJson) {
    EnterCriticalSection(&g_cs);

    if (SUCCEEDED(errorCode) && resultObjectAsJson != NULL) {
        wcsncpy_s(g_szScriptResult, 65536, resultObjectAsJson, _TRUNCATE);
    } else {
        g_szScriptResult[0] = L'\0';
    }

    LeaveCriticalSection(&g_cs);

    /* Notify AutoIt */
    if (pThis->hNotifyWnd) {
        PostMessage(pThis->hNotifyWnd, WM_WV2_SCRIPT_COMPLETED, (WPARAM)errorCode, 0);
    }

    return S_OK;
}

/* VTable for ScriptHandler */
static void* ScriptHandler_VTable[] = {
    ScriptHandler_QueryInterface,
    ScriptHandler_AddRef,
    ScriptHandler_Release,
    ScriptHandler_Invoke
};

/* ============================================================================
 * Exported Functions
 * ============================================================================ */

__declspec(dllexport) BOOL __stdcall WV2Helper_Initialize(HWND hNotifyWnd) {
    if (!g_bInitialized) {
        InitializeCriticalSection(&g_cs);
        g_bInitialized = TRUE;
    }
    g_hNotifyWnd = hNotifyWnd;
    g_pEnvironment = NULL;
    g_pController = NULL;
    g_pWebView2 = NULL;
    return TRUE;
}

__declspec(dllexport) void __stdcall WV2Helper_Cleanup(void) {
    if (g_bInitialized) {
        EnterCriticalSection(&g_cs);

        if (g_pWebView2 != NULL) {
            ((ULONG (__stdcall *)(void*))(*((void***)g_pWebView2))[2])(g_pWebView2);
            g_pWebView2 = NULL;
        }
        if (g_pController != NULL) {
            ((ULONG (__stdcall *)(void*))(*((void***)g_pController))[2])(g_pController);
            g_pController = NULL;
        }
        if (g_pEnvironment != NULL) {
            ((ULONG (__stdcall *)(void*))(*((void***)g_pEnvironment))[2])(g_pEnvironment);
            g_pEnvironment = NULL;
        }

        LeaveCriticalSection(&g_cs);
        DeleteCriticalSection(&g_cs);
        g_bInitialized = FALSE;
    }
}

__declspec(dllexport) void* __stdcall WV2Helper_CreateEnvironmentHandler(HWND hNotifyWnd) {
    EnvironmentHandler* pHandler = (EnvironmentHandler*)malloc(sizeof(EnvironmentHandler));
    if (pHandler == NULL) return NULL;

    pHandler->lpVtbl = EnvHandler_VTable;
    pHandler->refCount = 1;
    pHandler->hNotifyWnd = hNotifyWnd ? hNotifyWnd : g_hNotifyWnd;

    return pHandler;
}

__declspec(dllexport) void* __stdcall WV2Helper_CreateControllerHandler(HWND hNotifyWnd) {
    ControllerHandler* pHandler = (ControllerHandler*)malloc(sizeof(ControllerHandler));
    if (pHandler == NULL) return NULL;

    pHandler->lpVtbl = CtrlHandler_VTable;
    pHandler->refCount = 1;
    pHandler->hNotifyWnd = hNotifyWnd ? hNotifyWnd : g_hNotifyWnd;

    return pHandler;
}

__declspec(dllexport) void* __stdcall WV2Helper_CreateNavigationHandler(HWND hNotifyWnd) {
    NavigationHandler* pHandler = (NavigationHandler*)malloc(sizeof(NavigationHandler));
    if (pHandler == NULL) return NULL;

    pHandler->lpVtbl = NavHandler_VTable;
    pHandler->refCount = 1;
    pHandler->hNotifyWnd = hNotifyWnd ? hNotifyWnd : g_hNotifyWnd;

    return pHandler;
}

__declspec(dllexport) void* __stdcall WV2Helper_CreateWebMessageHandler(HWND hNotifyWnd) {
    WebMessageHandler* pHandler = (WebMessageHandler*)malloc(sizeof(WebMessageHandler));
    if (pHandler == NULL) return NULL;

    pHandler->lpVtbl = MsgHandler_VTable;
    pHandler->refCount = 1;
    pHandler->hNotifyWnd = hNotifyWnd ? hNotifyWnd : g_hNotifyWnd;

    return pHandler;
}

__declspec(dllexport) void* __stdcall WV2Helper_CreateScriptHandler(HWND hNotifyWnd) {
    ScriptHandler* pHandler = (ScriptHandler*)malloc(sizeof(ScriptHandler));
    if (pHandler == NULL) return NULL;

    pHandler->lpVtbl = ScriptHandler_VTable;
    pHandler->refCount = 1;
    pHandler->hNotifyWnd = hNotifyWnd ? hNotifyWnd : g_hNotifyWnd;

    return pHandler;
}

__declspec(dllexport) void* __stdcall WV2Helper_GetEnvironment(void) {
    return g_pEnvironment;
}

__declspec(dllexport) void* __stdcall WV2Helper_GetController(void) {
    return g_pController;
}

__declspec(dllexport) void* __stdcall WV2Helper_GetWebView2(void) {
    return g_pWebView2;
}

__declspec(dllexport) LPCWSTR __stdcall WV2Helper_GetLastMessage(void) {
    return g_szLastMessage;
}

__declspec(dllexport) LPCWSTR __stdcall WV2Helper_GetScriptResult(void) {
    return g_szScriptResult;
}

/* DLL Entry Point */
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
    switch (fdwReason) {
        case DLL_PROCESS_ATTACH:
            DisableThreadLibraryCalls(hinstDLL);
            break;
        case DLL_PROCESS_DETACH:
            if (g_bInitialized) {
                WV2Helper_Cleanup();
            }
            break;
    }
    return TRUE;
}
