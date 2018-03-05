# ehR

**Install**

```
library("devtools")
install_github("sysmedlab/ehR",dependencies = TRUE)
library(ehR)
```

**Documentation**
- See 'function_overview.csv' for an overview of all the functions (and data sets) included in the package

**Datasets & Crosswalks**
The package contains the following data sets and crosswalks:
- _dia_: Simulated EHR diagnosis data for 500 patients
- _ed_: Simulated EHR ED visit data for 500 patients
- _dem_: Simulated EHR demographics data for 500 patients
- _ehR_Cohort_: Simulated cohort & feature set
- _gagne_code_: ICD9 code - gagne co-morbidity category crosswalk (http://scholar.harvard.edu/gagne/software/combined-comorbidity-score) [* note the crosswalk included in the package includes gagne categories that are assigned a 0 weight (these are not included in the here referenced, publicly available version of the crosswalk)]
- _zocat_: ICD9 code - zocat crosswalk

**Notes**
- [1] Requires the newest version of devtools (https://github.com/hadley/devtools) to be installed
```
library(devtools)
install_github("hadley/devtools")
````

**Development**

- To Contribute:
````
# 1. Clone the repo
git clone https://github.com/sysmedlab/ehR.git

# 2. Make/Save any changes
- Ensure that all dependencies are included in @import statements at the function top and are
listed in the Imports (CRAN Dependency)/ Remotes (Github Dependency) fields of the DESCRIPTION file
- Recompile the package by executing the 'package_management/package_update.sh' script (Note: Prior to
compilation all dependencies need to be (manually) installed)
- Confirm that the compilation was successful by checking the 'package_management/package_update.Rout'
file and the 'function_overview.csv'

# 2. Create a new branch
git checkout -b [branch name]

# 3. Push all changes to the branch (assuming all changes have been committed)
git push origin [branch name]

* Note: Please see the contribution guide prior to committing
any changes: 'package_management/contribution_guide.txt'

# 4. Test by installing from the branch
library(devtools)
install_git("git://github.com/sysmedlab/ehR.git", branch = [branch name])
````

- To Contribute:
````
# 1. Clone the repo
git clone https://github.com/sysmedlab/ehR.git

# 2. Make/Save any changes
- Ensure that all dependencies are included in @import statements at the function top and are
listed in the Imports (CRAN Dependency)/ Remotes (Github Dependency) fields of the DESCRIPTION file
- Recompile the package by executing the 'package_management/package_update.sh' script (Note: Prior to
compilation all dependencies need to be (manually) installed)
- Confirm that the compilation was successful by checking the 'package_management/package_update.Rout'
file and the 'function_overview.csv'

# 2. Create a new branch
git checkout -b [branch name]

# 3. Push all changes to the branch (assuming all changes have been committed)
git push origin [branch name]

* Note: Please see the contribution guide prior to committing
any changes: 'package_management/contribution_guide.txt'

# 4. Test by installing from the branch
library(devtools)
install_git("git://github.com/sysmedlab/ehR.git", branch = [branch name])
````

- Package Management Tools
````
See 'package_management/' for

- (a) a script to update the package ('package_update.sh')

- (b) a script to load the package data and functions locally (rather than as a
package) ('load_package_locally.R')

````

***Fork the repo:***
1. Follow the steps listed on [GitHub Help: Fork A Repo](https://help.github.com/articles/fork-a-repo/). Make sure to add the original repo as `upstream`:  
`git remote add upstream https://github.com/sysmedlab/ehR.git`  
To verify:
```
$ git remote -v
origin	https://github.com/USERNAME/ehR.git (fetch)
origin	https://github.com/USERNAME/ehR.git (push)
upstream	git://github.com/sysmedlab/ehR.git (fetch)
upstream	git://github.com/sysmedlab/ehR.git (push)
```

2. To test a pull request, get a copy: `git fetch upstream pull/<id>/head:<branch>`
3. Switch to the branch: `git checkout <branch>`
4. After checking the PR, return to your branch `git checkout master`
