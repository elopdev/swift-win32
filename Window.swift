
import WinSDK

let WS_OVERLAPPEDWINDOW: UINT =
    UINT(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)

public protocol WindowDelegate: class {
  func OnDestroy(hWnd: HWND, wParam: WPARAM, lParam: LPARAM) -> LRESULT
  func OnPaint(hWnd: HWND, wParam: WPARAM, lParam: LPARAM) -> LRESULT
}

extension WindowDelegate {
  func OnDestroy(hWnd: HWND, wParam: WPARAM, lParam: LPARAM) -> LRESULT {
    PostQuitMessage(0)
    return 0
  }

  func OnPaint(hWnd: HWND, wParam: WPARAM, lParam: LPARAM) -> LRESULT {
    var psPaint: PAINTSTRUCT = PAINTSTRUCT()

    let hDC: HDC = BeginPaint(hWnd, &psPaint)
    FillRect(hDC, &psPaint.rcPaint, nil)
    EndPaint(hWnd, &psPaint)
    return 0
  }
}

public struct Window {
  public var delegate: WindowDelegate?
  private var `class`: WindowClass
  private var hWnd: HWND?

  public init(`class`: WindowClass, title: String, hInstance: HINSTANCE? = nil,
              hWndParent: HWND? = nil) {
    self.class = `class`
    title.withCString(encodedAs: UTF16.self) {
      self.hWnd =
          CreateWindowExW(0, self.class.wszClassName.baseAddress, $0,
                          WS_OVERLAPPEDWINDOW, /*CW_USEDEFAULT*/-1, /*CW_USEDEFAULT*/-1,
                          640, 480, hWndParent, nil, hInstance, nil)
    }
  }

  public func show() {
    ShowWindow(self.hWnd, SW_SHOW)
  }

  public func _runMessageLoop() {
    var msgMessage: MSG = MSG()
    while GetMessageW(&msgMessage, self.hWnd, 0, 0) != FALSE {
      TranslateMessage(&msgMessage)
      DispatchMessageW(&msgMessage)
    }
  }
}

