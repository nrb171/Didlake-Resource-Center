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
- [getNCEPReanalysis2](#getNCEPReanalysis)
- [getTCPRIMED](#getTCPRIMED)
- [extractStormFromTCRADAR](#extractStormFromTCRADAR)

## [Data Processing](#dataProcessing)

#### [Interpolation](#interpolation)
- [barnesInterpolation](#barnesInterp)

#### [Coordinate Transforms](#coordinateTransforms)
- [calculate_quadrantAverages](#calculate_quadrantAverages)
#### [Component Extraction](#geometricTransforms)
- [wavenumberDecomposition](#wavenumberDecomposition)
#### [Variable Conversion](#variableConversion)
- [Convective/Stratiform classification](#calculate_CSClass)
#### [Helpers](#helpers)
- [dBZ to dB and vice versa](#db2dbz)
- [meteo to math angles and vice versa](#met2mat)
- [UV to Radial/Tangential](#makeUVtoRadTan)
- [lat/lon differences to dx/dy/dr/dtheta](#latlon_to_disaz)

## [Data Analysis](#dataAnalysis)
- [calculate environmental shear](#calculateEnvironmentalShear)

## [Plotting Tools](#plottingTools)
#### [Colormaps](#colormaps)
- [cbrewer](#cbrewer)
- [colortables](#colortables)
#### [Printing Utilities](#printingUtilities)
- [plot_whiteSpaceOptimizer](#plot_whiteSpaceOptimizer)
- [print2](#print2)
#### [Plotting Functions](#plottingFunctions)
- [plot streamarrows](#plot_streamArrows)
- [plot TCRADAR](#plot_TCRADAR)
  
## [Publishing](#publishing)
- [glossary](#glossary)



## Code Index
<details><summary> <a name="barnesInterp">
   barnesInterp.m
   </a></summary>

   - Description: An iterative, gaussian weighted interpolation scheme <br>
   - Link: `./dataProcessing/barnesInterp.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="cbrewer">
      cbrewer.m
   </a></summary>
   - Description: useful tool for generating colormaps. The use cases here are more
   specific to meteorology. <br>
   - Link: `./plottingTools/colortables.m` <br>
   - Requirements: MATLAB, `plot_brewer_cmap.m`, `colorbrewer.mat`, `cbrewer.m` <br>
   - Related Items: `cbrewer.m`<br>
   </details>

<details><summary> <a name="calculate_CSClass">
      calculate_CSClass.m
   </a></summary>

   - Description: Calculate the convective-stratiform classification of a
   reflectivity field <br>
   - Link: `./dataProcessing/calculate_CSClass.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="calculateEnvironmentalShear">
      calculateEnvironmentalShear.m
   </a></summary>

   - Description: Calculate environmental shear from NCEP Reanalysis II data (see Kanamitsu et al., 2002) using the methodology described in Davis et al. (2008). Please read the documentation before using this script. <br>
   - Link: `./dataAnalysis/calculateEnvironmentalShear.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
      - Davis, C., C. Snyder, and A. C. Didlake, 2008: A vortex-based perspective of eastern Pacific tropical cyclone formation. Monthly Weather Review, 136, 2461–2477, https://doi.org/10.1175/2007MWR2317.1.<br>
      - Kanamitsu, B. Y. M., W. Ebisuzaki, W. Jack, S. Yang, J. J. Hnilo, M. Fiorino, and G. L. Potter, 2002: NCEP-DOE AMIP-II Reanalysis (R-2). Bulletin of the American Meteorological Society, 83, 1631–1644, https://doi.org/10.1175/BAMS-83-11-1631. <br>
   </details>


<details><summary> <a name="calculate_quadrantAverages">
      calculate_quadrantAverages.m
   </a></summary>

   - Description: Calculate quadrant averages from a given center location (in lat/lon) and direction. <br>
   - Link: `./dataProcessing/calculate_quadrantAverages.m` <br>
   - Requirements: MATLAB; [`met2mat.m`](#met2mat) <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="colortables">
      colortables.m
   </a></summary>

   - Description: useful tool for generating colormaps. The use cases here are more
   specific to meteorology. <br>
   - Link: `./plottingTools/colortables.m` <br>
   - Requirements: MATLAB, `plot_brewer_cmap.m`, `colorbrewer.mat`, `cbrewer.m` <br>
   - Related Items: `cbrewer.m`<br>
   </details>

<details><summary> <a name="db2dbz">
   db2dbz.m and dbz2d.m
   </a></summary>

   - Description: convert dBZ to dB and back again <br>
   - Link: `./dataProcessing/helpers/dbz2db.m` and `./dataProcessing/helpers/db2dbz.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="extractStormFromTCRADAR">
   extractStormFromTCRADAR.m
   </a></summary>

   - Description: Extract all variables of TCRADAR for a single storm. <br>
   - Link: `./dataProcessing/extractStormFromTCRADAR.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: 
      - TC-RADAR is available here: [TC-RADAR](https://www.aoml.noaa.gov/ftp/pub/hrd/data/radar/level3/)<br>
   </details>


<details><summary> <a name="getNCEPReanalysis">
   get_NCEP_reanalysis.m
   </a></summary>

   - Description: download the NCEP reanalysis data for a given year. <br>
   - Link: `./dataAquisition/get_NCEP_reanalysis.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>
   
<details><summary> <a name="getTCPRIMED">
   get_TCPRIMED.py
   </a></summary>

   - Description: download TCPRIMED data from AWS. <br>
   - Link: `./dataAquisition/get_TCPRIMED.py` <br>
   - Requirements: python <br>
   - Related Items: plot_TCPRIMED.m <br>
   </details>

<details><summary> <a name="latlon_to_disaz.m">
   latlon_to_disaz.m
   </a></summary>

   - Description: convert differences in latitude and longitude to zonal, meridional, meridian arclength, and azimuth <br>
   - Link: `./dataProcessing/helpers/latlon_to_disaz.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="makeUVtoRadTan">
   makeUVtoRadTan.m
   </a></summary>

   - Description: quickly convert between zonal and meridional wind to radial and tangential wind<br>
   - Link: `./dataProcessing/helpers/makeUVtoRadTan.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="met2mat">
   met2mat.m and mat2met.m
   </a></summary>

   - Description: handy conversions between math and meteo angle conventions. <br>
   - Link: `./dataProcessing/helpers/met2mat.m` and `./dataProcessing/helpers/met2mat.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>


<details><summary> <a name="plotTCPRIMED">
   plot_TCPRIMED.m
   </a></summary>

   - Description: plot TCPRIMED microwave. <br>
   - Link: `./plottingTools/get_TCPRIMED.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: get_TCPRIMED.py <br>
   </details>

<details><summary> <a name="plot_TCRADAR">
   plot_TCRADAR.m
   </a></summary>

   - Description: Plot TCRADAR data. <br>
   - Link: `./plottingTools/plot_TCRADAR.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: 
      - [extractStormFromTCRADAR](#extractStormFromTCRADAR) <br>
      - TCRADAR is available here: [TCRADAR](https://www.aoml.noaa.gov/ftp/pub/hrd/data/radar/level3/) <br>
   </details>

<details><summary> <a name="glossary">
   glossary.tex
   </a></summary>

   - Description: A list of commonly used METEO terms and definitions. <br>
   - Link: `./publishing/glossary.tex` <br>
   - Requirements: LaTeX <br>
   - Related Items: <br>
   </details>
<details><summary> <a name="plot_streamArrows">
   plot_streamArrows.m
   </a></summary>

   - Description: Plot curved vector fields. <br>
   - Link: `./plottingTools/plot_streamArrows.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="plot_whiteSpaceOptimizer">
      plot_whiteSpaceOptimizer.m
   </a></summary>

   - Description: A helper function to reduce the white space of a figure and
   modify all fonts. <br>
   - Link: `./plottingTools/plot_whiteSpaceOptimizer.m` <br>
   - Requirements: MATLAB, `plottingTools/plot_whiteSpaceOptimizer.m` <br>
   - Related Items: [print2](#print2) <br>
   </details>

<details><summary> <a name="print2">
   print2.m
   </a></summary>

   - Description: An easier to use printing function that supports rasterized and
   vector rendering <br>
   - Link: `./plottingTools/print2.m` <br>
   - Requirements: MATLAB, `plottingTools/plot_whiteSpaceOptimizer.m` <br>
   - Related Items: <br>
   </details>

<details><summary> <a name="wavenumberDecomposition">
   wavenumberDecomposition.m
   </a></summary>

   - Description: A tool to decompose centered cartesian tensor fields into integer wavenumber components <br>
   - Link: `./dataProcessing/wavenumberDecomposition.m` <br>
   - Requirements: MATLAB <br>
   - Related Items: <br>
   </details>
   