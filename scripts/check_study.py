"""检测浏览器窗口标题是否包含超星/学习通/智慧树等关键词"""
import ctypes, ctypes.wintypes

EnumWindows = ctypes.windll.user32.EnumWindows
GetWindowText = ctypes.windll.user32.GetWindowTextW
GetWindowTextLength = ctypes.windll.user32.GetWindowTextLengthW

titles = []

def each_window(hwnd, lParam):
    length = GetWindowTextLength(hwnd) + 1
    buffer = ctypes.create_unicode_buffer(length)
    GetWindowText(hwnd, buffer, length)
    if buffer.value:
        titles.append(buffer.value.lower())
    return True

WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_int, ctypes.c_int)
EnumWindows(WNDENUMPROC(each_window), 0)

keywords = ['chaoxing', '超星', '学习通', '学银在线', 'zhihuishu', '智慧树', 'mooc']
found = any(any(k in t for k in keywords) for t in titles)
exit(0 if found else 1)
