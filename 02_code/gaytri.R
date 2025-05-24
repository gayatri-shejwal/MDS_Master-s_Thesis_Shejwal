##  Subgroup/Facet Analysis
# For by-framing, by-job-role, by-region:
# Run separate models or include interactions.
# Add a facet_grid(~ ai_framing) or facet_grid(~ job_role) in your plot code.

#### AMCE Modeling and Output for Plotting

# You want to estimate the marginal effect of each candidate attribute (age, educ, ml, prog, soft, lead) on the probability of being chosen.

# Standard errors are clustered at the respondent level (RespID).
# You want output that can be used directly for a plot in the style of Hainmueller et al.

# Load necessary libraries
library(clubSandwich)
library(lmtest)
library(sandwich)
library(dplyr)

# Load your data
df <- read.csv("../01_data/long_subset_df.csv")

# Check your data
str(df)

# Factorize all attributes (important for AMCEs)
df <- df %>%
  mutate(
    age_group  = factor(age_group),
    educ       = factor(educ),
    ml         = factor(ml),
    prog       = factor(prog),
    soft       = factor(soft),
    lead       = factor(lead),
    ai_framing = factor(ai_framing),
    job_role   = factor(job_role)
  )

# Model: logistic regression with clustered SEs
# (Intercept is the baseline profile; all other levels are AMCEs vs baseline)
m <- glm(chosen ~ age_group + educ + ml + prog + soft + lead,
         data = df, family = binomial())

# Clustered robust variance-covariance matrix by respondent
vcovCL <- clubSandwich::vcovCR(m, cluster = df$RespID, type = "CR2")

# Get robust coefficient table
coefs <- lmtest::coeftest(m, vcovCL)

# Convert to data frame for plotting
amce <- as.data.frame.matrix(coefs)
colnames(amce) <- c("Estimate", "StdErr", "z", "p")
amce$var <- rownames(coefs)

# Compute confidence intervals
amce$upper <- amce$Estimate + 1.96 * amce$StdErr
amce$lower <- amce$Estimate - 1.96 * amce$StdErr

# (Optional) Remove the intercept for AMCE plotting
amce <- subset(amce, var != "(Intercept)")

# Relabel variable names for plotting (customize as needed)
amce$label <- amce$var
amce$label <- gsub("age_group", "Age: ", amce$label)
amce$label <- gsub("educ", "Education: ", amce$label)
amce$label <- gsub("ml_", "AI/ML: ", amce$label)
amce$label <- gsub("prog_", "Programming: ", amce$label)
amce$label <- gsub("soft_", "Soft skills: ", amce$label)
amce$label <- gsub("lead_", "Leadership: ", amce$label)

# Example: You might want to make these more readable, e.g.
amce$label <- gsub("_", " ", amce$label)
amce$label <- gsub("High", "High", amce$label)
amce$label <- gsub("Medium", "Medium", amce$label)
amce$label <- gsub("Low", "Low", amce$label)
amce$label <- gsub("None", "None", amce$label)
amce$label <- gsub("Basic", "Basic", amce$label)
amce$label <- gsub("Intermediate", "Intermediate", amce$label)
amce$label <- gsub("Advanced", "Advanced", amce$label)
amce$label <- gsub("Bachelor's", "Bachelor's", amce$label)
amce$label <- gsub("Master's", "Master's", amce$label)
amce$label <- gsub("PhD", "PhD", amce$label)

# Sort or reorder as needed for plotting (optional)
amce <- amce[order(amce$label),]

# Quick check
print(amce[, c("var", "Estimate", "StdErr", "upper", "lower", "label")])

# Ready for plotting!
library(ggplot2)
ggplot(amce, aes(x=Estimate, y=reorder(label, Estimate))) +
  geom_vline(xintercept=0, linetype="dotted", color="gray50") +
  geom_pointrange(aes(xmin=lower, xmax=upper), size=0.8) +
  labs(
    y = "",
    x = "Change in log-odds of being chosen (AMCE)",
    title = "Effects of Candidate Attributes on Selection Probability"
  ) +
  theme_bw(base_size=14)

# If you want marginal probabilities instead of log-odds,
# transform: probability = plogis(Estimate), etc.
amce$prob <- plogis(amce$Estimate)
amce$prob_upper <- plogis(amce$upper)
amce$prob_lower <- plogis(amce$lower)


##### Fit a Pooled Model with Interactions

### To test, for example, if the effect of ml_Advanced is different in high vs low ai_framing, fit a model with interaction terms:

# Interaction model (include all main effects and their interaction with ai_framing)
m_contrast <- glm(
  chosen ~ age_group + educ + ml + prog + soft + lead +
    ai_framing * (ml + prog + soft + lead), 
  data = df, family = binomial()
)
vcovCL_contrast <- clubSandwich::vcovCR(m_contrast, cluster = df$RespID, type = "CR2")
coefs_contrast <- lmtest::coeftest(m_contrast, vcovCL_contrast)
coefs_contrast


### Build and Test Specific Contrasts
## Let’s say you want to test the difference in the effect of ml_Advanced between high and low AI framing:

# In your model, you’ll have:
#   ml_Advanced (main effect, e.g., when ai_framing = low)
# ai_framinghigh:ml_Advanced (difference in effect when ai_framing = high vs low)
# So the total effect for ml_Advanced under high framing is:
  
#   ml_Advanced + ai_framinghigh:ml_Advanced
# For low framing: just ml_Advanced
# To test if these differ (i.e., if the interaction is significant), the interaction term’s p-value is the test you want.
# But if you want to formally test the difference, use the car::linearHypothesis() function or manually compute the contrast.

##### Example: Test if Advanced AI/ML effect differs by framing
install.packages("car")
library(car)

# See all coefficients for reference
print(row.names(coefs_contrast))

# Test: is the effect of ml_Advanced significantly different between high and low framing?
# The null hypothesis is: (ml_Advanced + ai_framinghigh:ml_Advanced) - ml_Advanced = ai_framinghigh:ml_Advanced = 0

linearHypothesis(m_contrast, "mlml_None:ai_framinglow = 0", vcov.=vcovCL_contrast)


#### So, use the actual coefficient names as shown in your model:



# Effect in high framing (just the coefficient):
summary(m_contrast)$coefficients["mlml_None", ]

# Effect in low framing (sum and delta method for SE):
b <- coef(m_contrast)
# Names: "mlml_None", "mlml_None:ai_framinglow"
effect_low <- b["mlml_None"] + b["mlml_None:ai_framinglow"]

# SE using delta method:
V <- vcovCL_contrast
se_low <- sqrt(V["mlml_None", "mlml_None"] +
                 V["mlml_None:ai_framinglow", "mlml_None:ai_framinglow"] +
                 2*V["mlml_None", "mlml_None:ai_framinglow"])

# 95% CI
lower <- effect_low - 1.96 * se_low
upper <- effect_low + 1.96 * se_low

cat("ml_None, low framing: estimate =", effect_low, "SE =", se_low, "95% CI =", lower, upper, "\n")







