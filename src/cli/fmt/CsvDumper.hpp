// Copyright (c) Signal Estimator authors
// Licensed under MIT

#pragma once

#include "core/Config.hpp"
#include "core/Frame.hpp"
#include "fmt/IDumper.hpp"
#include "processing/MovAvg.hpp"

#include <cstdint>
#include <cstdlib>
#include <vector>

namespace signal_estimator {

// dumps samples with their timestamps to a csv file
// to reduce file size, can "compress" output by replacing each N
// samples with an average value among those samples, where N is
// defined by config.dump_compression
class CsvDumper : public IDumper {
public:
    CsvDumper(const Config& config);
    ~CsvDumper();

    CsvDumper(const CsvDumper&) = delete;
    CsvDumper& operator=(const CsvDumper&) = delete;

    bool open(const char* filename);
    void close();

    void write(std::shared_ptr<Frame> frame) override;

private:
    void print_line_(IOType type, nanoseconds_t timestamp);

    const Config config_;

    std::vector<MovAvg<double>> mavg_;
    uint64_t pos_ { 0 };

    FILE* fp_ {};
    std::vector<char> buf_;
};

} // namespace signal_estimator
