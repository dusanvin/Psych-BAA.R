# Psych-BAA.R
Psych-BAA.R is a R script that reads two sets of scores from a JSON file and identifies any systematic bias using Bland-Altman analysis (BAA). Results are saved in a text document. Designed for psychological research.

## Project Structure
### Psych-BAA.R
The main program where the calculation takes place. Change ```INSERT-YOUR-FILE-HERE.JSON``` to the JSON file containing the ratings.
### INSERT-YOUR-FILE-HERE.JSON
The sample JSON file containing ratings from ```human_rater``` and ```ai_rater```. Replace the ratings with your own.
### ICC-output.txt
The text file that contains the calculations, e.g.,
```
Bland-Altman Analysis
----------------------
Bias (mean difference): -2.758
Upper Limit of Agreement: 4.964
Lower Limit of Agreement: -10.480


T-Test for Systematic Bias
---------------------------
Mean difference: -2.758
95% CI: [-3.396, -2.121]
t = -8.546, p = 1.44e-14

Interpretation:
----------------
Since the mean difference (bias) is negative, rater1 is on average stricter than rater2.
The average rating for rater1 is: 7.70.
The average rating for rater2 is: 10.46.
This means that the ratings for rater1 are on average 2.76 points lower than the ratings of rater2.

May your BAAs be high and your p-values low! 
