# MDS_Master-s_Thesis_Shejwal
Repository for the Master's Thesis Study conducted by Gayatri Rajendra Shejwal at the Hertie School as a part of the Master's Degree in Data Science for Public Policy (MDS).

# Changing Cognitive Capital: A Conjoint Study on the Impact of AI Adoption on Skill Demand

This repository contains the data processing and analysis code for my Master's thesis in Data Science for Public Policy at the Hertie School (2025). The study investigates how organizational AI adoption influences employer preferences for candidate skills across generalist and specialist job roles.

## 📄 Contents

- `01_data/`: Complete survey data, with both raw and processed datasets along with:
  - `survey.pdf`: PDF version of the Qualtrics survey instrument
- `02_code/`: Complete R code used during the project
  - `01_data_cleaning_and_manipulation.Rmd`: Code for cleaning and reshaping raw Qualtrics survey exports into long format
  - `02_data_descriptives.Rmd`: Code for descriptive statistics of the collected data
  - `03_conjoint_analysis_and_results.Rmd`: Code for estimating ACPs and CACPs using Ganter's (2021) approach
- `03_functions/`: The ACP estimation functions used as they are from Ganter's GitHub here: https://github.com/flavienganter/preferences-conjoint-experiments
- `04_plots/`: Any plots, tables and visual outputs
- `preanalysis_plan.pdf`: Pre-registered pre-analysis plan submitted to OSF

## 🧪 Method Summary

The experiment employs a between-subjects 2×2 factorial design (AI Framing × Job Role), followed by five forced-choice conjoint tasks per respondent. Candidate attributes are randomized within each task, allowing estimation of causal effects of context and skill profiles on employer choice.

## 📎 Related Materials

- OSF Pre-Registration: [[https://osf.io/yourlink](https://osf.io/yourlink)](https://osf.io/hr6pg)
- Thesis Repository: (optional: Overleaf or PDF link)

## 📬 Contact

**Author**: Gayatri Rajendra Shejwal  
**Email**: g.shejwal@students.hery=tie-school.org
**Affiliation**: Hertie School – Master of Data Science for Public Policy (2025)
