# Optional: install packages if not already installed
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("jsonlite")) install.packages("jsonlite")

# Load libraries
library(ggplot2)
library(jsonlite)

# Load the JSON file (adjust the path as needed)
json_data <- fromJSON("INSER-YOUR-FILE-HERE.json")

# Extract scores
human_scores <- json_data$human_rater
ai_scores <- json_data$ai_rater

# Merge by ID to ensure alignment
merged_scores <- merge(human_scores, ai_scores, by = "Id", suffixes = c("_human", "_ai"))

# Create vectors for analysis
rater1 <- merged_scores$Score_human
rater2 <- merged_scores$Score_ai

# Calculate means
mean_human <- mean(rater1)
mean_ai <- mean(rater2)

# Bland-Altman statistics
diffs <- rater1 - rater2
means <- (rater1 + rater2) / 2
bias <- mean(diffs)
sd_diff <- sd(diffs)
loa_upper <- bias + 1.96 * sd_diff
loa_lower <- bias - 1.96 * sd_diff

# Bland-Altman results as text
blandr_text <- paste0(
  "Bland-Altman Analysis\n",
  "----------------------\n",
  "Bias (mean difference): ", sprintf("%.3f", bias), "\n",
  "Upper Limit of Agreement: ", sprintf("%.3f", loa_upper), "\n",
  "Lower Limit of Agreement: ", sprintf("%.3f", loa_lower), "\n"
)

# Print and save
cat(blandr_text)

# T-test for systematic bias (mean difference ≠ 0)
t_test_result <- t.test(diffs, mu = 0)

# Format t-test output
t_test_summary <- paste0(
  "\nT-Test for Systematic Bias\n",
  "---------------------------\n",
  "Mean difference: ", sprintf("%.3f", mean(diffs)), "\n",
  "95% CI: [", sprintf("%.3f", t_test_result$conf.int[1]),
  ", ", sprintf("%.3f", t_test_result$conf.int[2]), "]\n",
  "t = ", sprintf("%.3f", t_test_result$statistic),
  ", p = ", sprintf("%.3g", t_test_result$p.value), "\n"
)

cat(t_test_summary)

# Interpretation: Who rates more strictly? + display means
if (bias < 0) {
  interpretation <- paste0(
    "Interpretation:\n",
    "----------------\n",
    "Since the mean difference (bias) is negative, human raters are on average stricter than the AI.\n",
    "The average human rating is: ", sprintf("%.2f", mean_human), ".\n",
    "The average AI rating is: ", sprintf("%.2f", mean_ai), ".\n",
    "This means that the human ratings are on average ", sprintf("%.2f", abs(bias)), 
    " points lower than the AI ratings."
  )
} else if (bias > 0) {
  interpretation <- paste0(
    "Interpretation:\n",
    "----------------\n",
    "Since the mean difference (bias) is positive, the AI is on average stricter than the human raters.\n",
    "The average human rating is: ", sprintf("%.2f", mean_human), ".\n",
    "The average AI rating is: ", sprintf("%.2f", mean_ai), ".\n",
    "This means that the AI ratings are on average ", sprintf("%.2f", abs(bias)), 
    " points lower than the human ratings."
  )
} else {
  interpretation <- paste0(
    "Interpretation:\n",
    "----------------\n",
    "There is no systematic difference between human and AI ratings.\n",
    "The average human rating is: ", sprintf("%.2f", mean_human), ".\n",
    "The average AI rating is: ", sprintf("%.2f", mean_ai), "."
  )
}

cat("\n", interpretation, "\n")

# Save everything together
writeLines(c(blandr_text, t_test_summary, interpretation), "bland-altman-output.txt")
cat("Bland-Altman results saved to 'bland-altman-output.txt'\n")

# ---- ggplot2 Bland-Altman Plot ----
df <- data.frame(mean = means, diff = diffs)

p <- ggplot(df, aes(x = mean, y = diff)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = bias, color = "blue", linetype = "dashed", linewidth = 1) +
  geom_hline(yintercept = loa_upper, color = "red", linetype = "dotted", linewidth = 1) +
  geom_hline(yintercept = loa_lower, color = "red", linetype = "dotted", linewidth = 1) +
  annotate("text", x = min(df$mean), y = bias, label = sprintf("Bias = %.2f", bias), vjust = -1, hjust = 0, color = "blue") +
  annotate("text", x = min(df$mean), y = loa_upper, label = sprintf("+1.96 SD = %.2f", loa_upper), vjust = -1, hjust = 0, color = "red") +
  annotate("text", x = min(df$mean), y = loa_lower, label = sprintf("-1.96 SD = %.2f", loa_lower), vjust = 1.5, hjust = 0, color = "red") +
  labs(
    title = "Bland-Altman Plot: Human vs. AI",
    x = "Mean rating (Human & AI)",
    y = "Difference (Human - AI)"
  ) +
  theme_minimal(base_size = 14)

# Display plot
print(p)

# Save as PDF (vector)
# ggsave("bland-altman-plot_INSER-YOUR-FILE-HERE.pdf", plot = p, width = 7, height = 5)

# Save as PNG (high-res raster)
# ggsave("bland-altman-plot_INSER-YOUR-FILE-HERE.png", plot = p, width = 7, height = 5, dpi = 300)
