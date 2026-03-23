# IoCAT
Iohexol Clearance Analysis Tool (IoCAT) is a visualisation tool for calculating the GFR based on the terminal plasma clearance of iohexol

To cite the tool : <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.19186448.svg" width="200">



## Prerequisites for using IoCAT
IoCAT was built in [R](https://www.r-project.org) , an open source programming language using the [Shiny package](https://shiny.rstudio.com), a web application framework for R. All required code can be found in this github repository.

## Input type for IoCAT calculation
IoCAT works with standard Excel files (.xlsx) which can be downloaded in the app

<img src="https://github.com/Guyon-J/IoCAT/blob/main/Images/Template.png" width="300">

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
| preinjection_g | Weight of full syringe (in g) |
| postinjection_g | Weight of empty syringe (in g) |
| injected_vol_ml | Injected volume (in mL) |
|  |  |
| time_0_raw | injection time (in min)  |
| times_raw | sampling time (in min)  |
| concs_raw | Iohexol concentration (in μg/mL or mg/L) at each sampling time point |

Once your data has been loaded, it will be transformed for analysis. 

#### Formula

Conversion of concentrations to ln(concentrations)

df <- data.frame(Time, Conc)


| Info             	| Detail                                                                           	|
|----------------------	|----------------------------------------------------------------------------------	|
| Body Surface Area (BSA) | $$0.007184 \times \text{Weight}^{0.425} \times \text{Height}^{0.725}$$ (Dubois & Dubois formula) |
| Body Mass Index (BMI) | $$\frac{Weight}{(Height / 100)^2}$$ |
|  |  |
| Linear model | model = lm(Conc ~ Time, data = df) |
|  | $$Intercept = coef(model)[1]$$ -> $$C_0 = e^{Intercept}$$|
|  | $$Slope = coef(model)[2]$$ -> $$k_e = abs(Slope)$$|
|  | $$AUC = k_e / C_0$$|
|  |  |
| Iohexol clearance | $$Cl = Dose / AUC$$ |
| Brochner-Mortensen correction | $$GFR = (Cl \times 0.990778) - (0.001218 \times Cl^2)$$ |
| Normalized Cl | $$GFR_n = GFR / BSA * 1.73$$ |

#### Displaying results

The main advantage of this application is that it enables you to visualize both the linear regression and the residuals, making it easier to identify outliers.
In addition, using data from the literature, it is possible to visualize the patient’s status based on their age and expected GFR, as well as to evaluate their kidney function.
Finally, all results can be exported as a PNG or TIFF file

<img src="https://github.com/Guyon-J/IoCAT/blob/main/Images/UI.png" width="800">

## Author
IoCAT was created at the Faculty of Medical Sciences of the [University of Bordeaux](https://www.u-bordeaux.fr/) by [Joris Guyon](https://orcid.org/0000-0001-6692-2890).

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

## Note
The results provided are for informational purposes only and do not constitute professional advice or an automated decision. The user retains full responsibility for verifying the data and for the consequences of its use.
The software is provided “as is,” without warranty of any kind. Under no circumstances shall the author be held liable for any damages, direct or indirect, arising from the use of or inability to use the results produced by this tool.
