## [Introduction](#1-introduction)

This document will outline each file in the project and explain its purpose. A
brief description of each file and similar files will also be provided.

The codebase is split into several sections focusing on different
computing tasks. The sections are arranged in a logical order that reflects the
typical workflow of a project:

- [Data Aquisition](#data-aquisition)
  - Tools for collecting data from the internet.
- [Data Processing](#data-processing)
  - Tools for processing data into a usable format.
  - e.g. [#interpolation](#interpolation)
    [#coordinateTransforms](#coordinateTransforms)
    [#geometricTransforms](#geometricTransforms) [#variableConversion](#variableConversion)
- [Data Analysis](#data-analysis)
  - Tools for analyzing data to extract information.
- [Plotting Tools](#plotting-tools)
  - General tools for plotting data.
  - e.g. [#colormaps](#colormaps)

## Usage Instructions

If you intend to add a new file to the project, please copy/paste the below code
block to the end of the `INDEX.md` in alphabetical order and update to reflect
the file.
```
<details>
<summary> <a name="uniqueID">
   NameofFile
</a></summary>

- Description: A brief description of the file. <br>
- Link: A link to the file. <br>
- Requirements: A list of requirements for the file. <br>
- Related Items: A list of related files.<br>
</details>
```
And provide a link to the file in the relevant section.
```
[Link](#uniqueID)
```

This will create a collapsible section that can be expanded to view the details of the file.
## [Data Aquisition](#dataAquisition)

## [Data Processing](#dataProcessing)

#### [Interpolation](#interpolation)

#### [Coordinate Transforms](#coordinateTransforms)
#### [Geometric Transforms](#geometricTransforms)
#### [Variable Conversion](#variableConversion)
- [Convective/Stratiform classification](#calculate_CSClass)

## [Data Analysis](#dataAnalysis)

## [Plotting Tools](#plottingTools)
#### [Colormaps](#colormaps)


####
<details>
<summary> <a name="calculate_CSClass">
   calculate_CSClass
</a></summary>

- Description: Calculate the convective-stratiform classification of a
  reflectivity field <br>
- Link: `./dataProcessing/calculate_CSClass.m` <br>
- Requirements: MATLAB <br>
- Related Items: <br>
</details>