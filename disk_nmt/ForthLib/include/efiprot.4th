
\ File attributes
#define EFI_FILE_READ_ONLY      0x01
#define EFI_FILE_HIDDEN         0x02
#define EFI_FILE_SYSTEM         0x04
#define EFI_FILE_RESERVIED      0x08
#define EFI_FILE_DIRECTORY      0x10
#define EFI_FILE_ARCHIVE        0x20
#define EFI_FILE_VALID_ATTR     0x37

STRUCTURES{

\ typedef EFI_FILE_PROTOCOL EFI_FILE;

\ File information types

 0
    *FIELD                  FI.Size
    *FIELD                  FI.FileSize
    *FIELD                  FI.PhysicalSize
    /EFI_TIME FIELD         FI.CreateTime
    /EFI_TIME FIELD         FI.LastAccessTime
    /EFI_TIME FIELD         FI.ModificationTime
    *FIELD                  FI.Attribute
   2 FIELD                  FI.FileName
 CONSTANT /EFI_FILE_INFO
[IFNDEF] F_Open
    8 \ Revision
    *FIELD F_Open
    *FIELD F_Close
    *FIELD F_Delete
    *FIELD F_Read
    *FIELD F_Write
    *FIELD F_GetPosition
    *FIELD F_SetPosition
    *FIELD F_GetInfo
    *FIELD F_SetInfo
    *FIELD F_Flush
    *FIELD F_OpenEx
    *FIELD F_ReadEx
    *FIELD F_WriteEx
    *FIELD F_FlushEx
DROP
[THEN]
}STRUCTURES

\
\ Simple file system protocol
\

ALIGN
CREATE EFI_SIMPLE_FILE_SYSTEM_GUID
    0x964e5b22 L, 0x6459 W, 0x11d2 W, 
    0x8e C, 0x39 C, 0x0 C, 0xa0 C, 0xc9 C, 0x69 C, 0x72 C, 0x3b C,

