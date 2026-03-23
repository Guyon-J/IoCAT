# IoCAT
A Shiny app for calculating the GFR based on the terminal plasma clearance of iohexol

## Prerequisites for using IoCAT
Iohexol Clearance Analysis Tool (IoCAT) was built in [R](https://www.r-project.org) , an open source programming language using the [Shiny package](https://shiny.rstudio.com), a web application framework for R. All required code can be found in this github repository.

## Input type for IoCAT calculation
IoCAT works with standard Excel files (.xlsx) which can be downloaded in the app

### Input variables for **IoCAT**
#### Data
| Variable             	| Detail                                                                           	|
|----------------------	|----------------------------------------------------------------------------------	|
| last_name | last name of the patient |
| first_name | first name of the patient |
| birth_date | Date of birth (DD/MM/YYYY) |
| date_of_visit | Date of visit (DD/MM/YYYY) |
| gender | Woman (W) or Man (M) |
| weight_kg | weight in kg |
| height_cm | size in cm |
| eGFR | estimated GFR |
|  |  |
| iodine_mg_ml | Omnipaque formulation : 140, 180, 240, 300 or 350 |
| preinjection_g | Weight of full syringe (in mg) |
| postinjection_g | Weight of empty syringe (in mg) |
| injected_vol_ml | Injected volume (in mL) |
|  |  |
| time_0_raw | injection time (in min)  |
| times_raw | sampling time (in min)  |
| concs_raw | Iohexol concentration (in μg/mL or mg/L) at each sampling time point |

Once your data has been loaded, it will be transformed for analysis. 

## Author

IoCAT was created at the Faculty of Medical Sciences of the [University of Bordeaux](https://www) by [Joris Guyon](https://www).

## Copyright
[![License](https://img.shields.io/badge/Licence-GPL%20v3.0-orange.svg)]
IoCAT is licensed under the [GNU General Public License (GPL) v3.0](https://github.com/Guyon-J/iohexol_clearance/blob/main/LICENSE). In a nutshell, this means that this package:

- May be used for commercial purposes and private purposes

- May be modified, although:
  - Modifications **must** be released under the same license when distributing the package
  - Changes made to the code **must** be documented

- May be distributed, although:
  - Source code **must** be made available when the package is distributed
  - A copy of the license and copyright notice **must** be included.

- Comes with a LIMITATION of liability

- Comes with NO warranty
