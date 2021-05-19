## udma-i2cm1

|S.No   | Test-Case  | Mode  | Required  | Status  | Pass/Fail|
| ---   |  ---  |  ---  |  ---  |  ---  |  ---|
|1      | Set clock frequency  | Blocking Operation  | Yes  | Done  | Pass|
|2  | Wait for idle  | Blocking Operation  | Yes  | In-Progress  | |
|3  | Read register  | Non-Blocking Operation  | No  | Done  | Pass|
|4  | Read non-existant register  | Non-Blocking Operation  | No  | In-Progress  | |
|5  | Write register  | Non-Blocking Operation  | No  | In-Progress  | |
|6  | Write non-existant register  | Non-Blocking Operation  | No  | In-Progress  | |
|7  | Read N of M registers, M >= N  | Non-Blocking Operation  | No  | In-Progress  | |
|8  | Read N of M registers, M < N  | Non-Blocking Operation  | No  | In-Progress  | |
|9  | Write N of M registers, M >= N  | Non-Blocking Operation  | No  | In-Progress  | |
|10  | Write N of M registers, M < N  | Non-Blocking Operation  | No  | In-Progress  | |
|11  | Read register  | Blocking Operation  | Yes  | In-Progress  | |
|12  | Read non-existant register  | Blocking Operation   | Yes  | In-Progress  | |
|13  | Write register  | Blocking Operation  | Yes  | Done  | Pass|
|14  | Write non-existant register  | Blocking Operation  | Yes  | Done  | Pass|
|15  | Read N of M registers, M >= N  | Blocking Operation  | Yes  | Done  | Pass|
|16  | Read N of M registers, M < N  | Blocking Operation  | Yes  | In-Progress  | |
|17  | Write N of M registers, M >= N  | Blocking Operation  | Yes  | In-Progress  | |
|18  | Write N of M registers, M < N  | Blocking Operation  | Yes  | In-Progress  | |