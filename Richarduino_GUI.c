//Compiles with gcc -o Richarduino_GUI.exe Richarduino_GUI.c -lgdi32 -lws2_32
#include <winsock2.h>
#include <windows.h>
#include <math.h>
#include <stdio.h>
#include <stdint.h> // Added for uintptr_t type

#define XADC_DATA_LENGTH 512

// Function declarations
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
void OnButtonClickGainQuater(HWND hwnd);
void OnButtonClickGainOne(HWND hwnd);
void OnButtonClickGainTen(HWND hwnd);
void OnButtonClickGainTwenty(HWND hwnd);
void OnButtonClickConnect(HWND hwnd);
void OnButtonClickPowerOn(HWND hwnd);
void OnButtonClickPoke(HWND hwnd);
void OnButtonClickPeek(HWND hwnd);
void OnButtonClickCheckVersion(HWND hwnd);
void OnButtonClickPlot(HWND hwnd);
void OnButtonClickSetTrigger(HWND hwnd);
int GetTextBoxLineCount(HWND hwndTextBox);
void ReadAndUpdateUARTData();
void ReadAndPlotData();
void AppendTextToUARTDataTextBox(const char* text);
void shiftAndInsert(char arr[], char newInput);
void PlotData(HDC hdc, unsigned char* data, int length);

// Global variables
HANDLE hThread;
HWND hwnd;
unsigned char xadcData[4096];
COLORREF plotBackgroundColor = RGB(0, 0, 0);    
COLORREF axisColor = RGB(255, 255, 255);        
COLORREF waveColor = RGB(0, 0, 255);          
int triggerLevel = 127;
BOOL set_trigger = FALSE;
int i = 0;
HWND triggerLevelTextBox;
HWND gainTextBox;
HWND pokeAddressTextBox;
HWND pokeDataTextBox;
HWND peekAddressTextBox;
HWND uartDataTextBox; // Added to display UART data
HANDLE hSerial;
HANDLE hfile;
PAINTSTRUCT ps;
HDC hdc;

// Plot dimensions
int plotWidth = 1024;
int plotHeight = 400;
int xOffset = 50;
int yOffsetTop = 240;
int yOffsetBottom = 640;

// Global variables to track button clicks
BOOL readData = FALSE;
BOOL plotData = FALSE;
// Global variable for trigger event
HANDLE hTriggerEvent;


// Entry point
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // Register the window class
    const char *className = "Richarduino_GUI";
    WNDCLASSEX wc;
    wc.cbSize        = sizeof(WNDCLASSEX);
    wc.style         = 0;
    wc.lpfnWndProc   = WindowProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hInstance;
    wc.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
    wc.lpszMenuName  = NULL;
    wc.lpszClassName = className;
    wc.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);
    if(!RegisterClassEx(&wc))
    {
        MessageBox(NULL, "Window Registration Failed!", "Error!",
            MB_ICONEXCLAMATION | MB_OK);
        return 0;
    }

    // Create the window
    hwnd = CreateWindowEx(
        WS_EX_CLIENTEDGE, className, "Richarduino GUI", WS_OVERLAPPEDWINDOW | WS_SIZEBOX,
        CW_USEDEFAULT, CW_USEDEFAULT, 1300, 700, // Changed initial window size
        NULL, NULL, hInstance, NULL
    );

    if (hwnd == NULL) {
        MessageBox(NULL, "Window creation failed!", "Error", MB_ICONERROR);
        return 1;
    }

    // Initialize trigger event
    hTriggerEvent = CreateEvent(NULL, FALSE, FALSE, NULL);



    // // Generate actual sine wave data
    // double frequency = 0.05;
    // // Generate oscillating data points from 0 to 1
    // for (int x = 0; x < XADC_DATA_LENGTH; x++) {
    //     // Alternate between 0 and 1 based on the value of frequency
    //     if (x % (int)(1.0 / frequency) > 9) {
    //         xadcData[x] = 100; // Set to 1 when frequency allows
    //     } else {
    //         xadcData[x] = 0; // Set to 0 otherwise
    //     }
    // }

    // Gain button
    HWND gainButton1 = CreateWindow(
        "BUTTON", "Gain 0.25", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        10, 10, 80, 20, hwnd, (HMENU)1, hInstance, NULL
    );
    // Gain button
    HWND gainButton2 = CreateWindow(
        "BUTTON", "Gain 1", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        110, 10, 80, 20, hwnd, (HMENU)2, hInstance, NULL
    );
    // Gain button
    HWND gainButton3 = CreateWindow(
        "BUTTON", "Gain 10", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        10, 30, 80, 20, hwnd, (HMENU)11, hInstance, NULL
    );
    // Gain button
    HWND gainButton4 = CreateWindow(
        "BUTTON", "Gain 20", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        110, 30, 80, 20, hwnd, (HMENU)12, hInstance, NULL
    );
    // Trigger button
    HWND triggerPlusButton = CreateWindow(
        "BUTTON", "Set Trigger", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        290, 10, 100, 30, hwnd, (HMENU)3, hInstance, NULL
    );
    // Trigger level display
    triggerLevelTextBox = CreateWindow(
        "EDIT", "0-255", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
        400, 15, 100, 20, hwnd, NULL, NULL, NULL);

    // Poke address text box
    pokeAddressTextBox = CreateWindow(
        "EDIT", "Address", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
        620, 15, 100, 20, hwnd, NULL, NULL, NULL);

    // Poke data text box
    pokeDataTextBox = CreateWindow(
        "EDIT", "Data", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
        730, 15, 100, 20, hwnd, NULL, NULL, NULL);

    // UART data text box
    uartDataTextBox = CreateWindow(
        "EDIT", "", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL | ES_MULTILINE | ES_READONLY,
        10, 60, 560, 150, hwnd, NULL, NULL, NULL); // Added to display UART data

    // Poke button for poke address and data
    HWND pokeButton = CreateWindow(
        "BUTTON", "Poke", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        840, 10, 100, 30, hwnd, (HMENU)5, hInstance, NULL
    );

    // Peek address textbox
    peekAddressTextBox = CreateWindow(
        "EDIT", "", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
        730, 55, 100, 20, hwnd, NULL, NULL, NULL
    );

    // Peek button
    HWND peekButton = CreateWindow(
        "BUTTON", "Peek", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        840, 50, 100, 30, hwnd, (HMENU)6, hInstance, NULL
    );

    // Button for checking version
    HWND checkVersionButton = CreateWindow(
        "BUTTON", "Check Version", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        840, 90, 100, 30, hwnd, (HMENU)7, hInstance, NULL
    );

    // Connect button for firmware downloader
    HWND powerOnButton = CreateWindow(
        "BUTTON", "Power On", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        840, 130, 100, 30, hwnd, (HMENU)10, hInstance, NULL
    );

    HWND connectButton = CreateWindow(
        "BUTTON", "Connect", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        840, 170, 100, 30, hwnd, (HMENU)8, hInstance, NULL
    );
    // Connect button for firmware downloader
    HWND plotButton = CreateWindow(
        "BUTTON", "Plot", WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
        1140, 240, 100, 30, hwnd, (HMENU)9, hInstance, NULL
    );



    // Show the window
    ShowWindow(hwnd, nCmdShow);

    // Run the message loop
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);

        ReadAndUpdateUARTData();
        if(GetTextBoxLineCount(uartDataTextBox) > 9){
            SetWindowText(uartDataTextBox, "");
        }

        DWORD exitCode;
        if (hThread != NULL && GetExitCodeThread(hThread, &exitCode) && exitCode != STILL_ACTIVE) {
            // Thread has finished, close the handle
            CloseHandle(hThread);
            AppendTextToUARTDataTextBox("Closed plotting thread");
            hThread = NULL;
        }
    }

    return 0;
}

// Window procedure
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_COMMAND:
            if (LOWORD(wParam) == 1) {
                OnButtonClickGainQuater(hwnd);
            }
            if (LOWORD(wParam) == 2) {
                OnButtonClickGainOne(hwnd);
            }
            if (LOWORD(wParam) == 11) {
                OnButtonClickGainTen(hwnd);
            }
            if (LOWORD(wParam) == 12) {
                OnButtonClickGainTwenty(hwnd);
            }
            if (LOWORD(wParam) == 3) {
                OnButtonClickSetTrigger(hwnd);
            }
            if (LOWORD(wParam) == 5) {
                OnButtonClickPoke(hwnd);
            }
            if (LOWORD(wParam) == 6) {
                OnButtonClickPeek(hwnd);
            }
            if (LOWORD(wParam) == 7) {
                OnButtonClickCheckVersion(hwnd);
            }
            if (LOWORD(wParam) == 8) {
                OnButtonClickConnect(hwnd);
            }
            if (LOWORD(wParam) == 9) {
                OnButtonClickPlot(hwnd);
            }
            if (LOWORD(wParam) == 10) {
                OnButtonClickPowerOn(hwnd);
            }


            break;

        case WM_PAINT: {
            HDC hdc = BeginPaint(hwnd, &ps);
            PlotData(hdc, xadcData, XADC_DATA_LENGTH);
            EndPaint(hwnd, &ps);
        
            break;
        }

        case WM_DESTROY:
            PostQuitMessage(0);
            break;

        default:
            return DefWindowProc(hwnd, uMsg, wParam, lParam);
    }

    return 0;
}

// Function to redraw the plot
void RedrawPlot(HWND hwnd) {
    // Define the rectangle to invalidate (portion of the window to be redrawn)
    RECT invalidRect;
    invalidRect.left = xOffset;
    invalidRect.top = yOffsetTop;
    invalidRect.right = xOffset + plotWidth;
    invalidRect.bottom = yOffsetBottom;

    // Invalidate the specified rectangle for redraw
    InvalidateRect(hwnd, &invalidRect, TRUE);
    //UpdateWindow(hwnd);

}

int GetTextBoxLineCount(HWND hwndTextBox) {
    return (int)SendMessage(hwndTextBox, EM_GETLINECOUNT, 0, 0);
}

void ReadAndUpdateUARTData() {
    if (readData && hSerial != INVALID_HANDLE_VALUE) {
        char recvBuffer[50];
        DWORD bytesRead;
        
        // Read data from COM port
        if (ReadFile(hSerial, recvBuffer, sizeof(recvBuffer), &bytesRead, NULL)) {
            // Null terminate the received data
            recvBuffer[bytesRead] = '\0';

            HWND hwndUartData = uartDataTextBox;
            int len = GetWindowTextLength(hwndUartData);
            SendMessage(hwndUartData, EM_SETSEL, len, len);
            // Append received data to uartDataTextBox
            if (bytesRead > 0) {
                for(int i = 0; i < bytesRead; i++) {
                    // Convert byte to two-character hexadecimal string and append to textbox
                    char hexString[3];
                    sprintf(hexString, "%02X", (unsigned char)recvBuffer[i]);
                    SendMessage(hwndUartData, EM_REPLACESEL, 0, (LPARAM)hexString);
                }               

                
                // Append a newline character after each message
                SendMessage(hwndUartData, EM_SETSEL, len + bytesRead*2, len + bytesRead*2); // Adjusting for the length of the hex string
                SendMessage(hwndUartData, EM_REPLACESEL, 0, (LPARAM)"\r\n");
            }
        }
    }

    readData = FALSE;
}

void AppendTextToUARTDataTextBox(const char* text) {
    // Get the current text in the uartDataTextBox
    int textLength = GetWindowTextLength(uartDataTextBox);
    SendMessage(uartDataTextBox, EM_SETSEL, textLength, textLength);
    SendMessage(uartDataTextBox, EM_REPLACESEL, FALSE, (LPARAM)text);
}

// Function to open the UART port
BOOL OpenSerialPort() {
    // Open the COM port (COM4) for UART communication
    hSerial = CreateFile("\\\\.\\COM4", GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (hSerial == INVALID_HANDLE_VALUE) {
        MessageBox(NULL, "Failed to open COM port for UART communication!", "Error", MB_OK | MB_ICONERROR);
        return FALSE;
    }

    // Set COM port settings (baud rate, parity, etc.)
    DCB dcbSerialParams = { 0 };
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(hSerial, &dcbSerialParams)) {
        MessageBox(NULL, "Failed to get COM port state!", "Error", MB_OK | MB_ICONERROR);
        CloseHandle(hSerial);
        return FALSE;
    }
    dcbSerialParams.BaudRate = 921600; // Set baud rate to 115200
    dcbSerialParams.ByteSize = 8;         // 8 bits per byte
    dcbSerialParams.StopBits = ONESTOPBIT;// 1 stop bit
    dcbSerialParams.Parity   = NOPARITY;  // No parity
    if (!SetCommState(hSerial, &dcbSerialParams)) {
        MessageBox(NULL, "Failed to set COM port state!", "Error", MB_OK | MB_ICONERROR);
        CloseHandle(hSerial);
        return FALSE;
    }

    return TRUE;
}

// Function to close the UART port
void CloseSerialPort() {
    if (hSerial != INVALID_HANDLE_VALUE) {
        CloseHandle(hSerial);
    }
}

void OnButtonClickSetTrigger(HWND hwnd) {
    char triggerText[10];
    GetWindowText(triggerLevelTextBox, triggerText, 10);

    triggerLevel = atoi(triggerText);
    set_trigger = TRUE;
    SetEvent(hTriggerEvent);
}

void OnButtonClickCheckVersion(HWND hwnd) {
    // Send the character 'V' to the port
    char versionChar = 'V';
    DWORD bytesWritten;
    if (!WriteFile(hSerial, &versionChar, sizeof(versionChar), &bytesWritten, NULL)) {
        AppendTextToUARTDataTextBox("Failed to send version check command via UART!\n");
    } else {
        // Display confirmation message
        AppendTextToUARTDataTextBox("Version: ");
        readData = TRUE;
    }

}

void OnButtonClickConnect(HWND hwnd) {
    static BOOL connected = FALSE; // Indicates whether currently connected or not
    if (!connected) {
        // Connect to the COM port
        if (OpenSerialPort()) {
            // Change the button text to "Disconnect"
            SetWindowText(GetDlgItem(hwnd, 8), "Disconnect");
            connected = TRUE;
        }
    } else {
        // Disconnect from the COM port
        CloseSerialPort();

        // Change the button text back to "Connect"
        SetWindowText(GetDlgItem(hwnd, 8), "Connect");
        connected = FALSE;
    }
}

void toLowerCase(char *str) {
    while (*str) {
        *str = tolower(*str);
        str++;
    }
}

char * ctoh(char * txt){
    // Convert the hexadecimal data string to an integer
    toLowerCase(txt);
    int index = 0;
    unsigned char *bytes = (unsigned char *)malloc(4 * sizeof(unsigned char));
    for(int i=0; i<strlen(txt); i=i+2){
        char a,b;
        if(txt[i]<=57 && txt[i] >= 48){
            a = txt[i] - 48;
        }
        if(txt[i]<=102 && txt[i] >= 97){
            a = txt[i] - 87;
        }
        if(txt[i+1]<=57 && txt[i+1] >= 48){
            b = txt[i+1] - 48;
        }
        if(txt[i+1]<=102 && txt[i+1] >= 97){
            b = txt[i+1] - 87;
        }

        char tmp = a << 4 | b;
        bytes[index] = tmp;
        index++;
    }
    return bytes;
}

void OnButtonClickPoke(HWND hwnd) {
    DWORD bytesWritten;
    unsigned char *addressBytes;
    unsigned char *dataBytes;
    int index = 0;


    // Get the poke address
    char pokeAddressText[10]; // Including space for null terminator
    GetWindowText(pokeAddressTextBox, pokeAddressText, sizeof(pokeAddressText));
    
    // Convert the hexadecimal address string to an integer
    addressBytes = ctoh(pokeAddressText);

    // Get the poke data
    char pokeDataText[10]; // Including space for null terminator
    GetWindowText(pokeDataTextBox, pokeDataText, sizeof(pokeDataText));
    
    // Convert the hexadecimal data string to an integer
    dataBytes = ctoh(pokeDataText);

    const char * W = "W";
    
    // Write to the serial port
    if (!WriteFile(hSerial, W, 1, &bytesWritten, NULL)) {
        AppendTextToUARTDataTextBox("Failed to send data via UART!\r\n");
    } else {
        if (!WriteFile(hSerial, addressBytes, 4, &bytesWritten, NULL)) {
            AppendTextToUARTDataTextBox("Failed to send data via UART!\r\n");
        }else {
            if (!WriteFile(hSerial, dataBytes, 4, &bytesWritten, NULL)) {
                AppendTextToUARTDataTextBox("Failed to send data via UART!\r\n");
            }else{
                // Display the sent message in the UART data textbox
                AppendTextToUARTDataTextBox("Sent poke\r\n");
            }
        }
        
    }
}

void ReadAndPlotData(){
    DWORD bytesRead;
    unsigned char buffer;

    while(1){
        if(set_trigger){
            int prev = INT_MAX;
            int cur = INT_MAX;
            int index = -1;

            while(1){
                ReadFile(hSerial, &buffer, 1, &bytesRead, NULL);
                prev = cur;
                cur = (int)buffer;
                if(cur > prev && cur > triggerLevel){
                    break;
                }
            }
            
            xadcData[0] = buffer;

            //printf(" 1st: %d\n", bytesRead);
            int total_bytesRead = 0;
            while(total_bytesRead < 511){
                ReadFile(hSerial, xadcData+1, 511, &bytesRead, NULL);
                total_bytesRead += bytesRead;
                //printf("index: %d total_read: %d read: %d\n", index, total_bytesRead, bytesRead);
            }

            // for(int i=0; i<512; i++){
            //     printf("%d\n", (int)xadcData[i]);
            // }
            RedrawPlot(hwnd);
            //WaitForSingleObject(hTriggerEvent, INFINITE);
        }else{
            ReadFile(hSerial, xadcData, 512, &bytesRead, NULL);
            if(bytesRead < 512){
                ReadFile(hSerial, xadcData+bytesRead, 512-bytesRead, &bytesRead, NULL);
            }
            RedrawPlot(hwnd);
        }

        //printf("data: %u\n", (unsigned int)xadcData[total_bytes_read]);
        //total_bytes_read += bytesRead;
        //if(total_bytes_read >= 4096) total_bytes_read = 0;
        
        //printf("%d\n", total_bytes_read);

        //if(total_bytes_read % 512 == 511){
        
        //}
    }
    
}

void OnButtonClickPowerOn(HWND hwnd){
    DWORD bytesWritten;
    unsigned char power_addressBytes[] = {0xff, 0xff, 0xff, 0xf0};
    unsigned char power_dataBytes[] = {0x00, 0x00, 0x00, 0x01}; //UART output register address
    unsigned char on_addressBytes[] = {0xff, 0xff, 0xff, 0xf4};
    unsigned char on_dataBytes[] = {0x00, 0x00, 0x00, 0x01};

    // send starting address
    const char * W = "W";

    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, power_addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, power_dataBytes, 4, &bytesWritten, NULL);

    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, on_addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, on_dataBytes, 4, &bytesWritten, NULL);

}


void OnButtonClickPlot(HWND hwnd) {
    DWORD bytesWritten;
    unsigned char START_addressBytes[] = {0xff, 0xff, 0xff, 0xbc};
    unsigned char START_dataBytes[] = {0xff, 0xff, 0xff, 0xe4}; //UART output register address
    unsigned char LENGTH_addressBytes[] = {0xff, 0xff, 0xff, 0xb8};
    unsigned char LENGTH_dataBytes[] = {0x00, 0x00, 0x00, 0x01};
    unsigned char GO_addressBytes[] = {0xff, 0xff, 0xff, 0xb0};
    unsigned char GO_dataBytes[] = {0x00, 0x00, 0x00, 0x01};

    // send starting address
    const char * W = "W";

    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, START_addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, START_dataBytes, 4, &bytesWritten, NULL);

    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, LENGTH_addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, LENGTH_dataBytes, 4, &bytesWritten, NULL);

    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, GO_addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, GO_dataBytes, 4, &bytesWritten, NULL);
    
    set_trigger = FALSE;
    ResetEvent(hTriggerEvent);
    SetEvent(hTriggerEvent);
    // Check if the thread is already running
    if (hThread != NULL) {
        return;
    }

    // Create a new thread
    AppendTextToUARTDataTextBox("Start ploting\r\n");
    hThread = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)ReadAndPlotData, NULL, 0, NULL);
    if (hThread == NULL) {
        return;
    }
    
    
}

void OnButtonClickPeek(HWND hwnd) {
    // Get the peek address
    char peekAddressText[10];
    GetWindowText(peekAddressTextBox, peekAddressText, 100);
    unsigned char * addressBytes;

    addressBytes = ctoh(peekAddressText);

    // Construct the message to send
    const char * R = "R";
    DWORD bytesWritten;

    WriteFile(hSerial, R, 1 , &bytesWritten, NULL);
    
    // Write to the serial port
    if (!WriteFile(hSerial, addressBytes, 4, &bytesWritten, NULL)) {
        AppendTextToUARTDataTextBox("Failed to send data via UART!\r\n");
    } else {
        // Display confirmation message
        AppendTextToUARTDataTextBox("Peek: ");
        readData = TRUE;
    }
}

void OnButtonClickGainQuater(HWND hwnd){
    DWORD bytesWritten;
    const char * W = "W";
    unsigned char addressBytes[] = {0xff, 0xff, 0xff, 0xc4};
    unsigned char dataBytes[] = {0x00, 0x00, 0x00, 0x13};

    
    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, dataBytes, 4, &bytesWritten, NULL);

    AppendTextToUARTDataTextBox("Set gain\r\n");

}

void OnButtonClickGainOne(HWND hwnd){
    DWORD bytesWritten;
    const char * W = "W";
    unsigned char addressBytes[] = {0xff, 0xff, 0xff, 0xc4};
    unsigned char dataBytes[] = {0x00, 0x00, 0x00, 0x01};

    
    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, dataBytes, 4, &bytesWritten, NULL);

    AppendTextToUARTDataTextBox("Set gain\r\n");

}

void OnButtonClickGainTen(HWND hwnd){
    DWORD bytesWritten;
    const char * W = "W";
    unsigned char addressBytes[] = {0xff, 0xff, 0xff, 0xc4};
    unsigned char dataBytes[] = {0x00, 0x00, 0x00, 0x03};

    
    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, dataBytes, 4, &bytesWritten, NULL);

    AppendTextToUARTDataTextBox("Set gain\r\n");

}

void OnButtonClickGainTwenty(HWND hwnd){
    DWORD bytesWritten;
    const char * W = "W";
    unsigned char addressBytes[] = {0xff, 0xff, 0xff, 0xc4};
    unsigned char dataBytes[] = {0x00, 0x00, 0x00, 0x07};

    
    WriteFile(hSerial, W, 1, &bytesWritten, NULL);
    WriteFile(hSerial, addressBytes, 4, &bytesWritten, NULL);
    WriteFile(hSerial, dataBytes, 4, &bytesWritten, NULL);

    AppendTextToUARTDataTextBox("Set gain\r\n");

}

// Plot XADC data
void PlotData(HDC hdc, unsigned char* data, int length) {

    // Set the background color
    HBRUSH hBackgroundBrush = CreateSolidBrush(plotBackgroundColor);

    RECT plotRect;
    plotRect.left = xOffset;
    plotRect.top = yOffsetTop;
    plotRect.right = xOffset + plotWidth;
    plotRect.bottom = yOffsetBottom;

    int xPos = xOffset;
    int yTop = yOffsetTop;
    int yBot = yOffsetBottom;

    FillRect(hdc, &plotRect, hBackgroundBrush);
    DeleteObject(hBackgroundBrush);

    // Move to the initial point
    MoveToEx(hdc, xPos, yTop, NULL);

    // Draw X-axis label
    TextOut(hdc, xPos + plotWidth / 2 - 20, yTop - 20, "Voltage(V)", 10);

    // Draw Y-axis
    HPEN hAxisPen = CreatePen(PS_SOLID, 2, axisColor);
    SelectObject(hdc, hAxisPen);
    // Move back to the initial point
    xPos += plotWidth / 2;
    MoveToEx(hdc, xPos, yTop, NULL);
    LineTo(hdc, xPos, yBot);

    // Draw Y-axis ticks and labels
    int numTicks = 10; // Number of ticks you want to display
    int tickStep = 25; // Step size for ticks

    for (int i = 0; i < numTicks; i++) {
        int yPosTick = yBot - (int)((i * plotHeight * tickStep) / 255); // Calculate y-position of tick

        // Calculate the corresponding value
        int value = i * tickStep;
        char label[10];
        sprintf(label, "%d", value); // Convert value to string

        // Draw tick on the right side of the axis
        MoveToEx(hdc, xPos + 5, yPosTick, NULL);
        LineTo(hdc, xPos - 5, yPosTick);

        SetTextColor(hdc, RGB(255, 255, 255)); // Set text color to white
        SetBkColor(hdc, RGB(0, 0, 0));         // Set background color to black
        TextOut(hdc, xPos - 25, yPosTick - 7, label, strlen(label)); // Display label
    }

    // Move back to the initial point
    xPos -= plotWidth / 2;
    MoveToEx(hdc, xPos, yBot, NULL);

    // Draw X-axis
    LineTo(hdc, xPos + plotWidth, yBot);

    // Draw X-axis ticks and labels
    double timeIncrement = 0.1;
    for (double time = 0.0; time <= 5.0; time += timeIncrement) {
        int xPosTick = xPos + (int)(time / 5.0 * plotWidth);
        MoveToEx(hdc, xPosTick, yBot - 5, NULL);
        LineTo(hdc, xPosTick, yBot + 5); // Draw tick mark upward
    }

    // Move to the initial point for plotting data
    MoveToEx(hdc, xPos, yBot, NULL);

    // Set up pen for plotting
    HPEN hPen = CreatePen(PS_SOLID, 2, waveColor);
    SelectObject(hdc, hPen);

    // Plot the data
    for (int x = 0; x < XADC_DATA_LENGTH; x++) {
        double normalizedData = (int)data[x];
        int xPosPlot = x * 2; // Assuming each data point occupies 2 pixels
        int yPos = yBot - normalizedData / 255 * plotHeight; // Scale YADC data to plot coordinates
        LineTo(hdc, xPos + xPosPlot, yPos); // Draw line from previous point to current point
    }

    

    // Draw Y-axis label
    //TextOut(hdc, xPos - 65, yTop + plotHeight / 2 - 10, "Time(ms)", 8);

    DeleteObject(hPen);
    DeleteObject(hAxisPen);
}



