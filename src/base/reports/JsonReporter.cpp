// Copyright (c) Signal Estimator authors
// Licensed under MIT

#include "reports/JsonReporter.hpp"

#include <cstdio>

namespace signal_estimator {

JsonReporter::JsonReporter() {
    first_output_ = true;
}

JsonReporter::~JsonReporter() {
    if (!first_output_) {
        printf("\n]\n");
    }
}

void JsonReporter::report_latency(
    double sw_hw, double hw, int sma_window, double hw_avg) {
    if (first_output_) {
        printf("[\n");
        printf("  {\"sw_hw\": %f, \"hw\": %f, \"hw_avg%d\": %f}", sw_hw, hw, sma_window,
            hw_avg);
        first_output_ = false;
    } else {
        printf(",\n");
        printf("  {\"sw_hw\": %f, \"hw\": %f, \"hw_avg%d\": %f}", sw_hw, hw, sma_window,
            hw_avg);
    }
    fflush(stdout);
}

void JsonReporter::report_losses(
    double loss_rate, int sma_window, double avg_loss_rate, double loss_ratio) {
    if (first_output_) {
        printf("[\n");
        printf("  {\"rate\": %f, \"rate_avg%d\": %f, \"ratio\": %f}", loss_rate,
            sma_window, avg_loss_rate, loss_ratio);
        first_output_ = false;
    } else {
        printf(",\n");
        printf("  {\"rate\": %f, \"rate_avg%d\": %f, \"ratio\": %f}", loss_rate,
            sma_window, avg_loss_rate, loss_ratio);
    }
    fflush(stdout);
}

} // namespace signal_estimator
