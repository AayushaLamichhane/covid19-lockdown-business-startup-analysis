# Effects of COVID-19 Lockdown Duration on Business Start-ups

This repository contains the code and related files for the paper "Effects of COVID-19 Lockdown Duration on Business Start-ups: U.S. Analysis" by Aayusha Lamichhane. The code is written in Stata and can be used to reproduce the empirical results in the paper.

## Table of Contents
- [Description](#description)
- [Prerequisites](#prerequisites)
- [Running the Code](#running-the-code)
- [Data Sources](#data-sources)
- [Paper Link](#paper-link)
- [Contact Information](#contact-information)

## Description
This project examines the dynamic impact of COVID-19 lockdown durations on High Propensity Business Applications (HPBA) across the 50 states of the U.S. between January 2018 and November 2020, using a difference-in-differences (DiD) estimator. The code in this repository processes data and runs the econometric models used in the paper.

## Prerequisites
To run the code, you will need:
1. **Stata**: The provided `.do` file is a Stata script. Ensure you have Stata installed on your system.
2. **Data Files**: You will need the provided .dta file (combined_data.dta) (contains Business Formation Statistics from the U.S. Census Bureau, lockdown data from Ballotpedia, and COVID-19 case data from Our World in Data).

## Running the Code
1. Download or clone this repository to your local machine.
2. Open Stata and set the working directory to the folder where the `.do` and `.dta` file are located.
   ```
   cd "path_to_your_folder"
   ```
3. Run the Stata `.do` file:
   ```
   do econometric_analysis.do
   ```
   This will:
   - Load the required datasets
   - Process and clean the data
   - Estimate the difference-in-differences model for the analysis
   - Output the results in the Stata results window or as a log file (if specified)

Make sure you have the required datasets in the same directory or adjust the file paths in the `.do` file accordingly.

## Data Sources
- **Business Formation Statistics (BFS)**: This data can be downloaded from the U.S. Census Bureau website.
- **Lockdown Data**: Available from Ballotpedia.
- **COVID-19 Data**: Can be accessed through the Our World in Data platform.

## Paper Link
For more details about the methodology and results, please refer to the paper:  
[Effects of COVID-19 Lockdown Duration on Business Start-ups: U.S. Analysis](Advanced_Econometrics_Research_Paper.pdf).

## Contact Information
For questions regarding this repository or the code, please contact Aayusha Lamichhane at [lamichhaneaayusha@gmail.com].

---

This README provides the necessary instructions for setting up and running the code, along with references to the data and paper. You can customize the contact information and any specific paths in the `.do` file as per your setup.
