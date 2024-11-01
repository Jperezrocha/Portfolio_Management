# SMF Portfolio Analysis Automation

## Overview
This STATA project automates the portfolio analysis for the Student Managed Fund (SMF), providing comprehensive sector analysis, performance metrics, and risk analytics. The automation includes comparison against the S&P 500 benchmark and implements both traditional and Dietz return calculations.

## Features

### Sector Analysis
- Portfolio sector composition visualization
- S&P 500 sector composition comparison
- Automated sector weightings calculations
- Visual representation through customized pie charts

### Performance Analysis
- NAV (Net Asset Value) tracking
- Multiple time horizon analysis:
  - Since inception
  - YTD (Year to Date)
  - Semester performance
- Modified Dietz Method implementation
- Benchmark comparison with S&P 500

### Risk Metrics
- Beta calculation (multiple time periods)
- Tracking Error
- Standard Deviation
- Semi-Standard Deviation
- Covariance and Correlation analysis
- Sharpe Ratio
- Information Ratio

## Data Requirements
The script expects the following input files:
- Portfolio sectors data (`Portfolio_sectors.csv`)
- S&P 500 ratios data (`S&P500_ratios.csv`)
- NAV report from IBKR (`NAV_Oct_28.csv`)
- S&P 500 price data (`SPX_data.csv`)

## Visualization Outputs
1. Portfolio Composition by Sector
2. S&P 500 Composition by Sector
3. Performance Charts:
   - YTD Performance vs S&P 500
   - Since Inception Performance
   - Semester Performance
   - Modified Dietz Return Comparisons

## Technical Implementation
- Written in STATA
- Automated data cleaning and formatting
- Time series analysis
- Custom graphing parameters for professional visualization
- Modular structure for easy updates and maintenance

## Usage
1. Ensure all required data files are in the correct directory
2. Update file paths as needed
3. Run the main script to generate all analyses and visualizations
4. Output includes both numerical metrics and graphical representations

## Time Periods
The analysis covers multiple time periods:
- Since Inception (from 2015)
- Year to Date (YTD)
- Current Semester (Fall 2024)
