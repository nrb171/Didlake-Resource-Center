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
- [dBZ to dB and dB to dBZ](#db2dbz)

## [Data Analysis](#dataAnalysis)

## [Plotting Tools](#plottingTools)
#### [Colormaps](#colormaps)
- [cbrewer](#cbrewer)
- [colortables](#colortables)
#### [Printing Utilities](#printingUtilities)
- [plot_whiteSpaceOptimizer](#plot_whiteSpaceOptimizer)
- [print2](#print2)
#### [Plotting Functions](#plottingFunctions)
- [plot streamarrows](#plot_streamArrows)



## Code Index
<details>
<summary> <a name="calculate_CSClass">
   calculate_CSClass.m
</a></summary>

- Description: Calculate the convective-stratiform classification of a
  reflectivity field <br>
- Link: `./dataProcessing/calculate_CSClass.m` <br>
- Requirements: MATLAB <br>
- Related Items: <br>
</details>
<details>
<summary> <a name="cbrewer">
   cbrewer.m
</a></summary>

- Description: useful tool for generating colormaps <br>
- Link: `./plottingTools/cbrewer.m` <br>
- Requirements: MATLAB, `plot_brewer_cmap.m`, `colorbrewer.mat` <br>
- Related Items: `colortables.m`<br>
</details>


<details>
<summary> <a name="colortables">
   colortables.m
</a></summary>

- Description: useful tool for generating colormaps. The use cases here are more
 specific to meteorology. <br>
- Link: `./plottingTools/colortables.m` <br>
- Requirements: MATLAB, `plot_brewer_cmap.m`, `colorbrewer.mat`, `cbrewer.m` <br>
- Related Items: `cbrewer.m`<br>
</details>

<details>
<summary> <a name="db2dbz">
   db2dbz.m and dbz2d.m
</a></summary>

- Description: convert dBZ to dB and back again <br>
- Link: `./dataProcessing/dbz2db.m` and `./dataProcessing/db2dbz.m` <br>
- Requirements: MATLAB <br>
- Related Items: <br>
</details>

<details>
<summary> <a name="plot_streamArrows">
   plot_streamArrows.m
</a></summary>

- Description: Plot curved vector fields. <br>
- Link: `./plottingTools/plot_streamArrows.m` <br>
- Requirements: MATLAB <br>
- Related Items: <br>
</details>


<details>
<summary> <a name="plot_whiteSpaceOptimizer">
   plot_whiteSpaceOptimizer.m
</a></summary>

- Description: A helper function to reduce the white space of a figure and
  modify all fonts. <br>
- Link: `./plottingTools/plot_whiteSpaceOptimizer.m` <br>
- Requirements: MATLAB, `plottingTools/plot_whiteSpaceOptimizer.m` <br>
- Related Items: [print2](#print2) <br>
</details>

<details>
<summary> <a name="print2">
   print2.m
</a></summary>

- Description: An easier to use printing function that supports rasterized and
  vector rendering <br>
- Link: `./plottingTools/print2.,` <br>
- Requirements: MATLAB, `plottingTools/plot_whiteSpaceOptimizer.m` <br>
- Related Items: <br>
</details>